require_relative 'full_contact_db'
require_relative 'pipl_db'
require_relative 'user_request'
require 'email_verifier'
require 'google_custom_search_api'

TWO_PART_DOMAINS = %w(ac.at ac.il ac.uk aol.com apc.org asn.au att.com att.net boi.ie bp.com cmu.edu co.com co.gg co.il co.im co.in co.je co.jp co.nz co.th co.uk co.ukc co.za co.zw com.ar com.au com.bh com.br com.cn com.cy com.gt com.hk com.mk com.mt com.mx com.ng com.pk com.pt com.qa com.sg com.tr com.ua dcu.ie dsv.com edu.ge edu.in edu.tr eu.com ey.com gb.com ge.com gm.com gov.au gov.im gov.uk gt.com gwu.edu hhs.se hse.fi ibm.com ie.edu in.gov in.ua ing.com jnj.com ko.com kth.se kwe.com lls.com ltd.uk me.uk mit.edu mod.uk mps.it msn.com net.au net.il net.lb net.nz net.tr net.uk nhs.uk nyc.gov org.pl org.qa org.uk pkf.com plc.uk pwc.com rlb.com rr.com sas.com tac.com tcd.ie to.it uk.com uk.net unc.edu ups.com us.com utc.com yr.com)


class Profile < ActiveRecord::Base
  has_and_belongs_to_many :users
  serialize :notes, Hash
  serialize :emails

  def apply_template(email_template_id)
    first, last = split_name
    email_template = EmailTemplate.find(email_template_id)
    email_template.text.gsub('{First Name}', first).gsub('{Last Name}', last).gsub('{Company}', extract_company).gsub('{Position}', extract_position)
  end

  def set_primary_email(main_email)
    return unless emails.include?(main_email)
    a = emails
    a.delete(main_email)
    a.insert(0, main_email)
    self.update(emails: a)
  end

  def split_name
    name.split(' ')
  end

  def extract_company
    position.split(' at ').last || ''
  end

  def extract_position
    position.split(' at ').first || ''
  end

  def get_emails
    return emails unless emails.empty?

    update(emails: ['test@test.com'])
    return ['test@test.com']
    # get_emails_from_google
    return emails unless emails.empty?

    # get_emails_from_pipl
    return emails
  end

  def get_emails_from_pipl(update = true)
    account_id = nil
    account_id = "#{linkedin_id}@linkedin" unless linkedin_id.nil?
    account_id = "#{facebook_id}@facebook" unless facebook_id.nil?
    account_id = "#{twitter_id}@twitter" unless twitter_id.nil?
    return [] if account_id.nil?

    first, last = split_name
    person = PiplDb.find(first: first, last: last, account_id: account_id)
    return [] if person.nil?

    notes = person.to_hash
    notes.delete(:search_pointer)
    notes.delete(:emails)
    update(notes: notes, emails: person.emails.map(&:address)) if update
    emails
  end

  def get_emails_from_google(update = true)
    domain_options = []
    email_options = []

    begin
      company = extract_company[/.[a-zA-Z\.\- &]+/]
      return [] if company.nil?

      rejected_list = %w(linkedin twitter wikipedia apple facebook)
      query = "#{company} contacts"
      serp = GoogleCustomSearchApi.search(query, page: 1, googlehost: get_googlehost)
      raw_domain_options = serp['items'].map { |i| i['displayLink'] }.reject { |i| rejected_list.any? { |a| i.include? a } }

      raw_domain_options.each do |domain|
        if two_part_domain? domain
          domain_options << domain[/[^\.]+\.[^\.]+\.[a-z]+$/]
        else
          domain_options << domain[/[^\.]+\.[a-z]+$/]
        end
      end

      domain_options.uniq!

      first, last = split_name
      email_options = %W(#{first}.#{last} #{first[0]}#{last} #{first} #{last}).map(&:downcase)


      checker = EmailChecker.new(domain_options, email_options)
      email = checker.find_right_email

      if email
        update(emails: [email]) if update
        [email]
      else
        []
      end
    rescue => e
      logger.error "#{name}, #{position}, #{domain_options}, #{email_options}, #{e.message}"
      return []
    end

  end

  def get_googlehost
    location.include?('United Kingdom') ? 'google.co.uk' : 'google.com'
  end

  def self.get_emails_available(params)
    hash = {}
    threads = []
    new_profiles = []
    request = UserRequest.new(params)
    ids = request.ids
    case request.source
      when :linkedin
        profiles = Profile.where(linkedin_id: ids)

        # profiles.each { |profile| hash[profile.linkedin_id] = profile.emails_available }
        hash = profiles.pluck(:linkedin_id, :emails_available).to_h
        (ids - profiles.pluck(:linkedin_id)).each do |id|
          thread = Thread.new do
            p = request[id]
            emails_available = PiplDb.emails_available(name: p.name, account_id: "#{p.id}@linkedin".freeze)
            hash[p.id] = emails_available

            new_profiles << {linkedin_id: p.id, linkedin_url: "https://www.linkedin.com/profile/view?id=#{p.public_id}".freeze,
                             name: p.name, position: p.position, location: p.location, photo: p.photo, emails_available: emails_available}
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

    new_profiles.each do |profile_hash|
      Profile.create profile_hash
    end
    logger.warn hash
    hash
  end

  def two_part_domain?(domain)
    TWO_PART_DOMAINS.any? { |tp| domain[/#{tp}$/] }
  end

end

# {"name" => "Greg Barnett",
#  "source" => {"id" => "112123234", "public_id" => "ADEAAAau3WIBXuhln8uvxcEEG7Hb5M1I74oQyh4", "social_network" => "linkedin"},
#  "position" => "Co Founder & CTO at StarStock ltd",
#  "Location" => "London, United Kingdom",
#  "photo" => "https://media.licdn.com/mpr/mpr/shrink_100_100/AAEAAQAAAAAAAAXZAAAAJGE2OTQwZTkwLTM1OTYtNDc1YS05MDdhLTAzZmYyYTE5ODAwYw.jpg", "url" => "https://www.linkedin.com/profile/view?id=ADEAAAau3WIBXuhln8uvxcEEG7Hb5M1I74oQyh4&authType=OUT_OF_NETWORK&authToken=cOxw&locale=en_US&srchid=4120029691459362192716&srchindex=91&srchtotal=179817&trk=vsrp_people_res_name&trkInfo=VSRPsearchId%3A4120029691459362192716%2CVSRPtargetId%3A112123234%2CVSRPcmpt%3Aprimary%2CVSRPnm%3Afalse%2CauthType%3AOUT_OF_NETWORK",
#  "email" => "0 emails available",
#  "id" => "112123234"}