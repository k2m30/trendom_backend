require 'fullcontact'

class FullContactDb
  def self.find(person)
    FullContact.configure do |config|
      config.api_key = '5491a090221f93c0'.freeze
    end
    FullContact.person(person).to_hash
  end
end