require_relative 'full_contact_db'
require_relative 'pipl_db'
require_relative 'user_request'

class Profile < ActiveRecord::Base
  has_and_belongs_to_many :users
  serialize :notes, Hash
  serialize :emails

  def get_emails_and_notes
    return unless emails.empty?
    return if emails_available.zero?

    account_id = nil
    account_id = "#{linkedin_id}@linkedin" unless linkedin_id.nil?
    account_id = "#{facebook_id}@facebook" unless facebook_id.nil?
    account_id = "#{twitter_id}@twitter" unless twitter_id.nil?
    return [] if account_id.nil?

    person = PiplDb.find(name: name, account_id: account_id) #|| FullContactDb.find(params)
    notes = person.to_hash
    notes.delete(:search_pointer)
    notes.delete(:emails)
    update(notes: notes, emails: person.emails.map(&:address))
    person
  end

  def self.get_emails_available(params)
    hash = {}
    threads = []
    request = UserRequest.new(params)
    ids = request.ids
    case request.source
      when :linkedin
        profiles = Profile.where(linkedin_id: [ids])

        # profiles.each { |profile| hash[profile.linkedin_id] = profile.emails_available }
        hash = profiles.pluck(:linkedin_id, :emails_available).to_h

        (ids - profiles.pluck(:linkedin_id)).each do |id|
          thread = Thread.new do
            p = request[id]

            profile = Profile.new
            profile.linkedin_id = p.id
            profile.linkedin_url = "https://www.linkedin.com/profile/view?id=#{p.public_id}".freeze
            profile.name = p.name
            profile.position = p.position
            profile.location = p.location
            profile.photo = p.photo
            account_id = "#{p.id}@linkedin".freeze

            profile.emails_available = PiplDb.emails_available(name: p.name, account_id: account_id) #|| FullContactDb.find(params)

            profile.save
            hash[profile.linkedin_id] = profile.emails_available
          end
          threads << thread
        end

      when :facebook

    end
    unless threads.empty?
      threads.each(&:join)
      while threads.map(&:status).uniq != [false] do
        puts 'working'
        sleep 0.5
      end
    end

    logger.warn hash.to_json
    hash.to_json
  end
end

# {"name" => "Greg Barnett",
#  "source" => {"id" => "112123234", "public_id" => "ADEAAAau3WIBXuhln8uvxcEEG7Hb5M1I74oQyh4", "social_network" => "linkedin"},
#  "position" => "Co Founder & CTO at StarStock ltd",
#  "Location" => "London, United Kingdom",
#  "photo" => "https://media.licdn.com/mpr/mpr/shrink_100_100/AAEAAQAAAAAAAAXZAAAAJGE2OTQwZTkwLTM1OTYtNDc1YS05MDdhLTAzZmYyYTE5ODAwYw.jpg", "url" => "https://www.linkedin.com/profile/view?id=ADEAAAau3WIBXuhln8uvxcEEG7Hb5M1I74oQyh4&authType=OUT_OF_NETWORK&authToken=cOxw&locale=en_US&srchid=4120029691459362192716&srchindex=91&srchtotal=179817&trk=vsrp_people_res_name&trkInfo=VSRPsearchId%3A4120029691459362192716%2CVSRPtargetId%3A112123234%2CVSRPcmpt%3Aprimary%2CVSRPnm%3Afalse%2CauthType%3AOUT_OF_NETWORK",
#  "email" => "0 emails available",
#  "id" => "112123234"}