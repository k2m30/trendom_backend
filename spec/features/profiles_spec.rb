require 'capybara/rspec'
require 'capybara/rails'

require_relative 'features_common'

describe 'Profile manipulation' do
  before :each do
    login
    seed
    visit user_root_path
  end

  let(:user) { User.first }

  it 'can reveal emails' do

    visit reveal_emails_users_path
    visit user_root_path
    expect(user.profiles_with_hidden_emails.size).to be 0
    expect(all('.hidden-emails').size).to be 0
    expect(all('.visible-emails').size).to be 20
    expect(user.calls_left).to be 295
    expect(all('#reveal').size).to be 0
    expect(all('#download').size).to be 1
  end

  it 'can delete hidden profiles' do
    visit user_root_path
    expect(all('.hidden-emails').size).to be 5
    expect(user.profiles_with_hidden_emails.size).to be 5

    all('.remove-profile')[1].click
    expect(user.profiles_with_hidden_emails.size).to be 4
    expect(all('.hidden-emails').size).to be 4

    4.times do
      all('.remove-profile')[0].click
    end

    expect(user.profiles_with_hidden_emails.size).to be 0
    expect(all('.hidden-emails').size).to be 0
  end


end