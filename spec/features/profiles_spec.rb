require 'rails_helper'

require 'capybara/rspec'
require 'capybara/rails'

require_relative 'features_common'

RSpec.feature Profile, type: :feature do
  before :each do
    login
    seed
    visit user_root_path
  end

  let(:user) { User.first }

  it 'can mine some profiles in Linkedin it user has no profiles' do
    user.profiles.destroy_all
    visit user_root_path
    expect(all('#linkedin').size).to be 1
  end

  it 'can reveal emails' do
    expect(user.calls_left).to be 300
    expect(user.profiles_with_hidden_emails.size).to be 5

    user.reveal_emails
    user.reload
    visit user_root_path

    expect(all('.hidden-emails').size).to be 0
    expect(all('.visible-emails').size).to be 20
    expect(all('#reveal').size).to be 0
    expect(all('#download').size).to be 1
    expect(user.calls_left).to be 295
    expect(user.profiles_with_hidden_emails.size).to be 0
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