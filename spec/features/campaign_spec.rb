require_relative '../rails_helper'
require_relative '../spec_helper'

require 'capybara/rspec'
require 'capybara/rails'


# Capybara::Webkit.configure do |config|
#   config.allow_unknown_urls
#   config.ignore_ssl_errors
#   config.skip_image_loading
# end

def login
  OmniAuth.config.test_mode = true
  hash = OmniAuth::AuthHash.new(info: {email: 'mikhail.chuprynski@gmail.com', name: 'Mikhail Chuprynski'})
  OmniAuth.config.mock_auth[:google_oauth2] = hash

  visit new_user_session_path
  click_link 'Log in with Google'
end

def create_campaign(now = false, delete_profiles = 0)
  click_on 'Create new campaign'
  delete_profiles.times do
    all('a.remove-profile')[1].click
  end

  if now
    find('#send-now').click
  else
    find('#send-later').click
  end
end

describe 'Campaign', type: :feature do

  before :each do
    login
    seed
    visit user_root_path
  end

  let(:user) { User.first }

  it 'should login' do
    expect(page).to have_content 'Mikhail Chuprynski'
  end

  it 'creates seed data' do
    expect(User.count).to be 1
    seed
    expect(user.profiles.size).to be(40)
    visit user_root_path
    expect(user.active?).to be(true)
    expect(user.email_templates.size).to be 2

    expect(all('.hidden-emails').size).to be 25
    expect(all('.visible-emails').size).to be 15
  end

  it 'can choose profiles within a campaign' do
    click_on 'Create new campaign'
    expect(all('.profile').size).to be 15
    5.times do
      all('a.remove-profile')[1].click
    end
    expect(all('.profile').size).to be 10
  end

  it 'can create campaign with no limitations' do
    create_campaign(false, 0)

    expect(user.campaigns.size).to be 1
    expect(user.campaigns.first.profiles_ids.size).to eq 15
    expect(user.campaigns.first.email_template_id).to eq(user.email_templates.first.id)
    expect(user.campaigns.first.sent?).to be false

    visit user_root_path
    expect(all('.hidden-emails').size).to be 5
    expect(all('.visible-emails').size).to be 0
  end

  it 'can create campaign with limitations' do
    create_campaign(false, 5)

    expect(user.campaigns.size).to be 1
    expect(user.campaigns.first.profiles_ids.size).to eq 10
    expect(user.campaigns.first.email_template_id).to eq(user.email_templates.first.id)
    expect(user.campaigns.first.sent?).to be false

    visit user_root_path
    expect(all('.hidden-emails').size).to be 5
    expect(all('.visible-emails').size).to be 5
  end

  it 'can create several campaigns' do
    create_campaign(false, 10) #10 left
    expect(user.campaigns.size).to be 1

    visit user_root_path
    create_campaign(false, 5) #5 left
    expect(user.campaigns.size).to be 2

    expect(user.campaigns.first.profiles_ids.size).to eq 5
    expect(user.campaigns.last.profiles_ids.size).to eq 5

    visit user_root_path
    expect(all('.hidden-emails').size).to be 5
    expect(all('.visible-emails').size).to be 5
  end

  it 'can delete campaign' do
    create_campaign(false, 5)
    expect(user.campaigns.size).to be 1

    visit user_root_path
    expect(all('.hidden-emails').size).to be 5
    expect(all('.visible-emails').size).to be 5

    visit campaigns_path
    click_on 'Destroy'
    expect(user.campaigns.size).to be 0

    visit user_root_path
    expect(all('.hidden-emails').size).to be 5
    expect(all('.visible-emails').size).to be 15
  end

  it 'can send campaigns now' do

  end

  it 'can send campaigns later' do

  end

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