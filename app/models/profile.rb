require_relative 'full_contact_db'
require_relative 'pipl_db'

class Profile < ActiveRecord::Base
  has_and_belongs_to_many :users
  serialize :notes, Hash

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

end
