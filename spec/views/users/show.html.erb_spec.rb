require 'rails_helper'

# Тест на шаблон users/show.html.erb

RSpec.describe "users/show", type: :view do
  before(:each) do
    assign(:user, (
      FactoryBot.build_stubbed(:user, name: 'Вася')
    ))

    render
  end

  # пользователь видит там свое имя
  it 'show his name' do
    expect(rendered).to match 'Вася'
  end

  # текущий пользователь (и только он) видит там кнопку для смены пароля
  # describe '1' do
  #   before(:each) do
  #     assign(:user, (
  #     FactoryBot.build_stubbed(:user, name: 'Вася')
  #     ))
  #   end
  #
  #   it 'should ' do
  #
  #
  #     expect(rendered).not_to match 'Петя'
  #     expect(rendered).to match 'Вася'
  #   end
  # end

  #
  #
  # # странице отрисовываются фрагменты с игрой
  # it 'should ' do
  #
  #   expect(rendered).to match 'Вася'
  #   expect(rendered).to have_content 'User game goes here'
  # end
  #
  # private
  #
  # def render_partial
  #   render stub_template 'users/_game.html.erb' => 'User game goes here'
  # end
end
