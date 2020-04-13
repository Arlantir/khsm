require 'rails_helper'

# Тест на шаблон users/show.html.erb

RSpec.describe "users/show", type: :view do
  context "when user watch user's page" do
    before(:each) do
      user = FactoryBot.create(:user, name: 'Вася')
      @games = FactoryBot.build_stubbed(:game, current_level: 13, prize: 400, audience_help_used: false)
      assign(:user, user)
      assign(:games, @games)
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
      render partial: 'users/game', object: @games

      expect(rendered).to match '13'
      expect(rendered).to match '400 ₽'
      expect(rendered).to match '50/50'
    end
  end

  context "when anonumous watch user's page" do
    before(:each) do
      assign(:user, FactoryBot.build_stubbed(:user))

      render
    end

    # анонимный юзер, не видит кнопки "сменить имя и пароль"
    it 'current user' do
      expect(rendered).to_not match 'Сменить имя и пароль'
    end
  end
end
