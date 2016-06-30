require 'pipl'

KEYS = %w(BUSINESS-PREMIUM-DEMO-uw9fxpygvzs7mrucz7vp1gub BUSINESS-DEMO-qc9f5f4wvdwbu46qt43sr5nw BUSINESS-DEMO-o8u26xca0288p17opt7vi5e5 BUSINESS-PREMIUM-DEMO-66spkvy0o4ynmjnyxmcdxqt2)

class PiplDb
  def self.find(person_hash)
    response = get_response(person_hash, 'email'.freeze)
    return response.person
  end

  def self.emails_available(person_hash)
    return rand(0..4) if Rails.env.test?
    response = get_response(person_hash, 'email and phone and ethnicity and image'.freeze)
    if response.present? and response.available_data.present? and response.available_data.basic.present?
      response.available_data.basic.emails
    else
      0
    end
  end

  private

  def self.get_response(person_hash, match_requirements)
    begin
      person = Pipl::Person.new
      person.add_field Pipl::Name.new(first: person_hash[:first], last: person_hash[:last])
      person.add_field Pipl::UserID.new content: person_hash[:account_id]
      api_key = Rails.env.production? ? ENV['PIPL'].freeze : KEYS.sample
      Pipl::client.search person: person, match_requirements: match_requirements, api_key: api_key
    rescue Pipl::Client::APIError => e
      Rails.logger.error e.message
      Rails.logger.error person_hash
      sleep rand(0.4..0.6)
      retry
    end

  end
end