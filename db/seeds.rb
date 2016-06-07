User.first.profiles.delete_all
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