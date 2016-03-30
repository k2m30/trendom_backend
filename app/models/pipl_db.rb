require 'pipl'

class PiplDb
  def self.find(person_hash)
    # result = {}
    # result[:emails] = ['mikhail.chuprynski@gmail.com', '1m@tut.by'].join(',')
    # return result

    first, last = extract person_hash[:name]
    person = Pipl::Person.new
    person.add_field Pipl::Name.new(first: first, last: last)
    person.add_field Pipl::UserID.new content: person_hash[:account_id]

    response = Pipl::client.search person: person, match_requirements: 'email'.freeze, api_key: 'BUSINESS-effn6ozaifex6jkmxzcenj0i'.freeze

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

  def self.extract(full_name)
    name = full_name.split(' ')
    first = name[0]
    last = name[1]
    return first, last
  end
end