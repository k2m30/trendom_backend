require 'capybara/rspec'
require 'capybara/rails'


def login
  OmniAuth.config.test_mode = true
  hash = OmniAuth::AuthHash.new(info: {email: 'mikhail.chuprynski@gmail.com', name: 'Mikhail Chuprynski'})
  OmniAuth.config.mock_auth[:google_oauth2] = hash

  visit new_user_session_path
  click_link 'Log in with Google'
end

def seed
  20.times do
    emails = []
    rand(1..6).times do
      emails << Faker::Internet.email
    end
    User.first.profiles.create(name: Faker::Name.name, position: Faker::Name.title << ' at ' << Faker::Company.name,
                               photo: Faker::Internet.url,
                               location: Faker::Address.city << ', ' << Faker::Address.country,
                               emails: emails, notes: {},
                               linkedin_url: Faker::Internet.url,
                               linkedin_id: Faker::Number.number(7), emails_available: emails.size)
  end

  User.first.update(revealed_ids: User.first.profiles.ids.shuffle[0..14], calls_left: 300, subscription_expires: Time.now + 1.month)
end

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