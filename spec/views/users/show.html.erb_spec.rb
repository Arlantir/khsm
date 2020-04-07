require 'rails_helper'

# Тест на шаблон users/show.html.erb

RSpec.describe "users/show", type: :view do

  before(:each) do
    assign(:user, [
      FactoryGirl.build_stubbed(:user, name: 'Вася')
    ])
    # binding.irb
    render
  end

  # пользователь видит там свое имя
  it 'show his name' do
    expect(rendered).to match 'Вася'
  end
  # текущий пользователь (и только он) видит там кнопку для смены пароля


  # странице отрисовываются фрагменты с игрой
end
