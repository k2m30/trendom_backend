def login
  OmniAuth.config.test_mode = true
  hash = OmniAuth::AuthHash.new(info: {email: 'mikhail.chuprynski@gmail.com', name: 'Mikhail Chuprynski'}, credentials: {token: 'aaa', expires_at: 12345678})
  OmniAuth.config.mock_auth[:google_oauth2] = hash

  visit new_user_session_path
  click_link 'Log in with Google'
end

def seed(n = 20)
  n.times do
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

