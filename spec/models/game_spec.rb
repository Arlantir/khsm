# (c) goodprogrammer.ru

require 'rails_helper'
require 'support/my_spec_helper' # наш собственный класс с вспомогательными методами

# Тестовый сценарий для модели Игры
# В идеале - все методы должны быть покрыты тестами,
# в этом классе содержится ключевая логика игры и значит работы сайта.
RSpec.describe Game, type: :model do
  # пользователь для создания игр
  let(:user) { FactoryGirl.create(:user) }

  # игра с прописанными игровыми вопросами
  let(:game_w_questions) { FactoryGirl.create(:game_with_questions, user: user) }

  # Группа тестов на работу фабрики создания новых игр
  context 'Game Factory' do
    it 'Game.create_game! new correct game' do
      # генерим 60 вопросов с 4х запасом по полю level,
      # чтобы проверить работу RANDOM при создании игры
      generate_questions(60)

      game = nil
      # создaли игру, обернули в блок, на который накладываем проверки
      expect {
        game = Game.create_game_for_user!(user)
      }.to change(Game, :count).by(1).and(# проверка: Game.count изменился на 1 (создали в базе 1 игру)
        change(GameQuestion, :count).by(15).and(# GameQuestion.count +15
          change(Question, :count).by(0) # Game.count не должен измениться
        )
      )
      # проверяем статус и поля
      expect(game.user).to eq(user)
      expect(game.status).to eq(:in_progress)
      # проверяем корректность массива игровых вопросов
      expect(game.game_questions.size).to eq(15)
      expect(game.game_questions.map(&:level)).to eq (0..14).to_a
    end
  end


  # тесты на основную игровую логику
  context 'game mechanics' do

    # правильный ответ должен продолжать игру
    it 'answer correct continues game' do
      # текущий уровень игры и статус
      level = game_w_questions.current_level
      q = game_w_questions.current_game_question
      expect(game_w_questions.status).to eq(:in_progress)

      game_w_questions.answer_current_question!(q.correct_answer_key)

      # перешли на след. уровень
      expect(game_w_questions.current_level).to eq(level + 1)
      # ранее текущий вопрос стал предыдущим
      expect(game_w_questions.previous_game_question).to eq(q)
      expect(game_w_questions.current_game_question).not_to eq(q)
      # игра продолжается
      expect(game_w_questions.status).to eq(:in_progress)
      expect(game_w_questions.finished?).to be_falsey
    end

    # тест на проверку текущего игрового вопроса
    it 'current game question' do
      # создадим игру
      game_w_questions
      # вытащим первый вопрос
      q = Question.first.text

      expect(game_w_questions.current_game_question.text).to eq(q)
    end

    # тест на проверку первого вопроса (для начала игры)
    it 'previous_level' do
      expect(game_w_questions.previous_level).to eq(-1)
    end

    it 'take_money! finishes the game' do
      # берем игру и отвечаем на текущий вопрос
      q = game_w_questions.current_game_question
      game_w_questions.answer_current_question!(q.correct_answer_key)

      # взяли деньги
      game_w_questions.take_money!

      prize = game_w_questions.prize
      expect(prize).to be > 0

      # проверяем что закончилась игра и пришли деньги игроку
      expect(game_w_questions.status).to eq :money
      expect(game_w_questions.finished?).to be_truthy
      expect(user.balance).to eq prize
    end

    # группа тестов на проверку статуса игры
    context '.status' do
      # перед каждым тестом "завершаем игру"
      before(:each) do
        game_w_questions.finished_at = Time.now
        expect(game_w_questions.finished?).to be_truthy
      end

      it ':won' do
        game_w_questions.current_level = Question::QUESTION_LEVELS.max + 1
        expect(game_w_questions.status).to eq(:won)
      end

      it ':fail' do
        game_w_questions.is_failed = true
        expect(game_w_questions.status).to eq(:fail)
      end

      it ':timeout' do
        game_w_questions.created_at = 1.hour.ago
        game_w_questions.is_failed = true
        expect(game_w_questions.status).to eq(:timeout)
      end

      it ':money' do
        expect(game_w_questions.status).to eq(:money)
      end
    end

    # группа тестов на проверку ответов пользователя
    describe '#answer_current_question!' do
      context 'when answer is correct' do

        context 'and question is last' do
          let(:correct_answer) { game_w_questions.current_game_question.correct_answer_key }
          before { game_w_questions.answer_current_question!(correct_answer) }

          it 'answer to the last question' do
            # повышаем уровень игры до последнего
            game_w_questions.update_attribute(:current_level, 14)

            # проверяем, что ответ правильный
            expect(game_w_questions.answer_current_question!(correct_answer)).to be true

            # взяли деньги
            game_w_questions.take_money!

            # проверяем приз
            prize = game_w_questions.prize
            expect(prize).to eq(1_000_000)

            # проверяем что юзер победил и пришли деньги игроку
            expect(game_w_questions.status).to eq :won
            expect(game_w_questions.finished?).to be true
            expect(user.balance).to eq prize
          end
        end

        context 'and timeout' do
          let(:correct_answer) { game_w_questions.current_game_question.correct_answer_key }
          before { game_w_questions.answer_current_question!(correct_answer) }

          it 'answer the question' do
            game_w_questions.created_at = 1.hour.ago
            game_w_questions.is_failed = true

            # при ответе возвращаем false, так как игра закончена
            expect(game_w_questions.answer_current_question!(correct_answer)).to be false
            # статус почему закончилась игра
            expect(game_w_questions.status).to eq(:timeout)
          end
        end

        context 'and normal case' do
          let(:correct_answer) { game_w_questions.current_game_question.correct_answer_key }
          before { game_w_questions.answer_current_question!(correct_answer) }

          it 'answer correctly' do
            # проверяем, что ответ правильный
            expect(game_w_questions.answer_current_question!(correct_answer)).to be true

            # игра продолжается
            expect(game_w_questions.status).to eq(:in_progress)
            expect(game_w_questions.finished?).to be false
          end
        end
      end

      context 'when answer is wrong' do
        let(:correct_answer) { !game_w_questions.current_game_question.correct_answer_key }
        before { game_w_questions.answer_current_question!(correct_answer) }

        it 'answer incorrect' do
          # проверяем, что ответ неправильный
          expect(game_w_questions.answer_current_question!(correct_answer)).to be false

          # игра не продолжается
          expect(game_w_questions.status).to_not eq(:in_progress)
          expect(game_w_questions.finished?).to be true
        end
      end
    end
  end
end