class UserRequest
  attr_accessor :profiles, :uid, :email, :source

  def initialize(params)
    @profiles = []

    hash = params.to_h.deep_symbolize_keys
    @uid = hash[:uid]
    @email = hash[:email]

    if hash[:data].is_a? String
      hash[:data] = JSON.parse(hash[:data].gsub('=>', ':'))
      hash[:data].map {|h| h.deep_symbolize_keys!}
    end

    hash[:data].map do |json|
      @profiles << Person.new(json)
    end
    @source = @profiles.first.social_network.to_sym
  end

  def [](id)
    @profiles.select{|profile| profile.id.to_i == id.to_i }.first
  end
end

class Person
  attr_accessor :name, :social_network, :position, :location, :photo, :id, :public_id

  def initialize(json)
    @name = json[:name]
    @social_network = json[:source][:social_network]
    @public_id = json[:source][:public_id]
    @position = json[:position]
    @location = json[:location]
    @photo = json[:photo]
    @id = json[:source][:id]
  end
# {"name" => "Greg Barnett",
#  "source" => {"id" => "112123234", "public_id" => "ADEAAAau3WIBXuhln8uvxcEEG7Hb5M1I74oQyh4", "social_network" => "linkedin"},
#  "position" => "Co Founder & CTO at StarStock ltd",
#  "Location" => "London, United Kingdom",
#  "photo" => "https://media.licdn.com/mpr/mpr/shrink_100_100/AAEAAQAAAAAAAAXZAAAAJGE2OTQwZTkwLTM1OTYtNDc1YS05MDdhLTAzZmYyYTE5ODAwYw.jpg", "url" => "https://www.linkedin.com/profile/view?id=ADEAAAau3WIBXuhln8uvxcEEG7Hb5M1I74oQyh4&authType=OUT_OF_NETWORK&authToken=cOxw&locale=en_US&srchid=4120029691459362192716&srchindex=91&srchtotal=179817&trk=vsrp_people_res_name&trkInfo=VSRPsearchId%3A4120029691459362192716%2CVSRPtargetId%3A112123234%2CVSRPcmpt%3Aprimary%2CVSRPnm%3Afalse%2CauthType%3AOUT_OF_NETWORK",
#  "email" => "0 emails available",
#  "id" => "112123234"}
end