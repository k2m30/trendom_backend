require 'capybara/rspec'
require 'capybara/rails'

require_relative 'features_common'

describe 'User', type: :feature do
  before :each do
    login
    seed
    visit user_root_path
  end

  let(:user) { User.first }

  it 'reveal emails' do
    calls = user.calls_left
    hidden = user.profiles_with_hidden_emails.size
    expect(hidden).not_to be 0
    user.reveal_emails
    user.reload
    expect(user.progress).to be 100.0
    expect(user.profiles_with_hidden_emails.size).to be 0
    expect(user.calls_left).to be (calls - hidden)
    expect(user.profiles_with_revealed_emails.size).to be user.profiles.size
  end

  it 'doesn\'t allow to reveal more emails than calls left' do
    hidden = user.profiles_with_hidden_emails.size
    expect(hidden).not_to be 0
    user.update(calls_left: hidden - 1)
    user.reveal_emails
    user.reload
    expect(user.progress).to be 100.0
    expect(user.calls_left).to be 0
    expect(user.profiles_with_hidden_emails.size).to be 1
    expect(user.profiles_with_revealed_emails.size).to be (user.profiles.size - 1)
  end
end