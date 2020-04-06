require 'rails_helper'

# Тест на шаблон users/show.html.erb

RSpec.describe "users/show", type: :view do

  before(:each) do
    assign(:games, [
      FactoryGirl.build_stubbed(:user, id: 1, name: 'Вася')
    ])
    # binding.irb

  end

  # пользователь видит там свое имя
  it 'show his name' do
    render
    expect(rendered).to match 'Вася'
  end
  # текущий пользователь (и только он) видит там кнопку для смены пароля



  # странице отрисовываются фрагменты с игрой
  # it 'should ' do
  #   stub_template('users/_game.html.erb' => 'User game goes here')
  #
  #   expect(page).to have_content('User game goes here')
  # end
end
