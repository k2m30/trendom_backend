require 'pipl'

class PiplDb
  def self.find(person_hash)
    first, last = extract person_hash[:name]
    person = Pipl::Person.new
    person.add_field Pipl::Name.new(first: first, last: last)
    person.add_field Pipl::UserID.new content: "#{person_hash[:linkedin_id]}@linkedin".freeze

    response = Pipl::client.search person: person, match_requirements: 'email'.freeze, api_key: 'BUSINESS-effn6ozaifex6jkmxzcenj0i'.freeze

    if response.person.nil?
      return nil
    end
    emails = response.person.emails.map(&:address)
    result = {}

    notes = response.person.to_hash
    notes.delete(:search_pointer)
    notes[:urls] = response.person.urls.map(&:url)
    result[:email] = emails.to_s
    result[:notes] = notes.to_s
    return result
  end

  def self.extract(full_name)
    name = full_name.split(' ')
    first = name[0]
    last = name[1]
    return first, last
  end
end