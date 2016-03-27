require_relative 'full_contact_db'
require_relative 'pipl_db'

class Person < ActiveRecord::Base
  has_and_belongs_to_many :users
  serialize :notes, Hash

  def self.get(params)
    person = Person.find_by_hash(linkedin_id: params[:linkedin_id])
    if person.present?
      return person.to_json
    else
      person = PiplDb.find(params) #|| FullContactDb.find(params)
      if person.present?
        return Person.create(params.merge!(person)).to_json
      else
        return {}
      end
    end
  end

  def Person.get_emails(params)
    hash = {}
    params['data'].map do |json|
      account_id = ''
      id = json['source']['id']
      case json['source']['social_network']
        when 'linkedin'
          person = Person.find_by(linkedin_id: id)
          if person.nil?
            person = Person.new
            person.linkedin_id = id
            account_id = "#{id}@linkedin"
          end
        when 'facebook'
        when 'twitter'
      end
      unless account_id.empty?
        result = PiplDb.find(name: json['name'], account_id: account_id) #|| FullContactDb.find(params)
        person.email = result[:emails].to_s
        person.notes = result[:notes]
        person.save
      end

      if person.email.nil? or person.email.empty?
        hash[id] = nil
      else
        hash[id] = person.email.split(',').sample.sub(/.*@/, '****@')
      end

    end
    logger.warn hash.to_json
    hash.to_json
  end


  def mask_email(emails)
    return nil if emails.empty?
    emails.first.sub(/.*@/, '****@')
  end
end

# a = '{
#     "name": "Nikolay Lagutko",
#     "linkedin": "123456",
#     "company": "InDataLabs",
#     "position": "Senior engineer",
#     "location": "London, UK"
# }'
#
# URI.encode_www_form(JSON.parse(a))
# http://localhost:3000/persons/find?name=Nikolay+Lagutko&linkedin=123456&company=InDataLabs&position=Senior+engineer&location=London%2C+UK

# http://localhost:3000/persons/find.json?name=Leigh+Bromby&linkedin_id=178274623&company=InDataLabs&position=Senior+engineer&location=London%2C+UK