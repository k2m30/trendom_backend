require 'rails_helper'

RSpec.describe Profile, type: :model do

  it 'should reveal emails from google' do
    profile = Profile.create(name: 'Max Thorne', location: 'London, United Kingdom', linkedin_id: 70299642, position: 'Managing Director Hospitality at JLL')
    emails = profile.get_emails_from_google
    expect(emails.size).not_to eq(0)
    expect(emails.first).to eq('max.thorne@jll.com')
  end

  it 'should reveal emails from pipl' do
    profile = Profile.create(name: 'Max Thorne', location: 'London, United Kingdom', linkedin_id: 70299642, position: 'Managing Director Hospitality at JLL')
    emails = profile.get_emails_from_pipl
    # expect(emails).not_to match_array([])
    expect(emails.first).to eq('full.email.available@business.subscription')
  end

end