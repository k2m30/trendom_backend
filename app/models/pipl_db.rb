require 'pipl'

class PiplDb
  def self.find(person_hash)
    # result = {}
    # result[:emails] = ['mikhail.chuprynski@gmail.com', '1m@tut.by'].join(',')
    # return result

    response = get_response(person_hash, 'email'.freeze)

    if response.person.nil?
      return {emails: '', notes: nil}
    end
    emails = response.person.emails.map(&:address).join(',')
    result = {}

    notes = response.person.to_hash
    notes.delete(:search_pointer)
    notes[:urls] = response.person.urls.map(&:url)
    result[:emails] = emails
    result[:notes] = notes
    return result
  end

  def self.emails_available(person_hash)
    response = get_response(person_hash, 'email and phone and ethnicity and image'.freeze)
    if response.present? and response.available_data.present? and response.available_data.basic.present?
      response.available_data.basic.emails
    else
      0
    end
  end

  private

  def self.get_response(person_hash, match_requirements)
    first, last = extract person_hash[:name]
    person = Pipl::Person.new
    person.add_field Pipl::Name.new(first: first, last: last)
    person.add_field Pipl::UserID.new content: person_hash[:account_id]
    Pipl::client.search person: person, match_requirements: match_requirements, api_key: 'BUSINESS-effn6ozaifex6jkmxzcenj0i'.freeze
  end

  def self.extract(full_name)
    name = full_name.split(' ')
    first = name[0]
    last = name[1]
    return first, last
  end
end