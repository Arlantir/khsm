require 'rails_helper'

# Тест на шаблон users/show.html.erb

RSpec.describe "users/show", type: :view do
  context "when user watch user's page" do
    before(:each) do
      user = FactoryBot.create(:user, name: 'Вася')
      assign(:user, user)
      sign_in user
      render
    end

    # пользователь видит там свое имя
    it 'show his name' do
      expect(rendered).to match 'Вася'
    end

    # текущий пользователь (и только он) видит там кнопку для смены пароля
    it 'current user' do
      expect(rendered).to match 'Сменить имя и пароль'
    end

    # на странице отрисовываются фрагменты с игрой
    it 'fragments with the game' do
      games = FactoryBot.build_stubbed(:game, id: 1, current_level: 10, prize: 1000)

      render_partial(games)

      expect(rendered).to match '1'
      expect(rendered).to match '10'
      expect(rendered).to match '1 000 ₽'
    end
  end

  context "when anonumous watch user's page" do
    before(:each) do
      assign(:user, (FactoryBot.build_stubbed(:user)))

      render
    end

    # анонимный юзер, не видит кнопки "сменить имя и пароль"
    it 'current user' do
      expect(rendered).to_not match 'Сменить имя и пароль'
    end
  end

  private

  # Метод, который рендерит фрагмент с соотв. объектами
  def render_partial(games)
    render partial: 'users/game', object: games
  end
end
