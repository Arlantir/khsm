# Как и в любом тесте, подключаем помощник rspec-rails
require 'rails_helper'

# Начинаем описывать функционал, связанный с созданием игры
RSpec.feature 'USER show a profile', type: :feature do
  # Создаим пару юзеров
  let(:user) { FactoryGirl.create :user }
  let(:other_user) { FactoryGirl.create :user, balance: 33000 }

  # создадим пару игр
  let!(:first_game) do
    FactoryGirl.create(
      :game, id: 1, user: other_user, finished_at: Time.parse('2020.03.01, 13:00'), current_level: 9, prize: 32000,
      fifty_fifty_used: false, audience_help_used: false, friend_call_used: false
    )
  end

  let!(:second_game) do
    FactoryGirl.create(
      :game, id: 2, user: other_user, finished_at: Time.parse('2020.04.01, 16:00'), current_level: 4, prize: 1000,
      fifty_fifty_used: false, audience_help_used: false, friend_call_used: false
    )
  end

  # Перед началом любого сценария нам надо авторизовать пользователя
  before(:each) do
    login_as user
  end

  # Сценарий просмотра профиля юзера
  scenario 'successfully' do
    # Заходим на главную
    visit user_path(other_user)

    # Ожидаем, что попадем на нужный url
    expect(page).to have_current_path '/users/1'

    # Отсутствует кнопка смены имени и пароля, если я не юзер
    expect(page).to_not have_content 'Сменить имя и пароль'

    # Ожидаем, что на экране правильно выведены данные
    expect(page).to have_content '1 000 ₽'
    expect(page).to have_content '50/50'
    expect(page).to have_content 'деньги'
    expect(page).to have_content '4'
  end
end
