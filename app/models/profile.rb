require_relative 'full_contact_db'
require_relative 'pipl_db'
require_relative 'user_request'

class Profile < ActiveRecord::Base
  has_and_belongs_to_many :users
  serialize :notes, Hash

  def self.get_emails(params)
    hash = {}
    params['data'].map do |json|
      account_id = ''
      id = json['source']['id']
      case json['source']['social_network']
        when 'linkedin'
          profile = Profile.find_by(linkedin_id: id)
          if profile.nil?
            profile = Profile.new
            profile.linkedin_id = id
            account_id = "#{id}@linkedin"
          end
        when 'facebook'
        when 'twitter'
      end
      unless account_id.empty?
        result = PiplDb.find(name: json['name'], account_id: account_id) #|| FullContactDb.find(params)
        profile.email = result[:emails].to_s
        profile.notes = result[:notes]
        profile.save
      end

      if profile.email.nil? or profile.email.empty?
        hash[id] = nil
      else
        hash[id] = profile.email.split(',').sample.sub(/.*@/, '****@')
      end

    end
    # logger.warn hash.to_json
    hash.to_json
  end

  def self.get_emails_available(params)
    hash = {}
    request = UserRequest.new(params)
    request.profiles.map do |p|
      account_id = ''
      case p.social_network
        when 'linkedin'
          profile = Profile.find_by(linkedin_id: p.id)
          if profile.nil?
            profile = Profile.new
            profile.linkedin_id = p.id

            profile.linkedin_url = "https://www.linkedin.com/profile/view?id=#{p.id}"

            profile.name = p.name
            profile.position = p.position
            profile.location = p.location
            profile.photo = p.photo
            account_id = "#{p.id}@linkedin"
          end
        when 'facebook'
        when 'twitter'
      end

      profile.emails_available = PiplDb.emails_available(name: p.name, account_id: account_id) #|| FullContactDb.find(params)
      profile.save

      hash[p.id] = profile.emails_available
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