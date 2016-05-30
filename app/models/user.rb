require 'csv'
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :trackable, :omniauthable, :omniauth_providers => [:google_oauth2]
  serialize :revealed_ids
  has_many :lists, dependent: :delete_all
  has_many :profiles, through: :lists
  has_many :templates, through: :lists

  after_create :create_lists

  def active?
    active = (calls_left > 0 and Time.now < subscription_expires)
    update(calls_left: 0, plan: '') unless active
    active
  end

  def enough_calls?
    calls_left >= profiles_with_hidden_emails.size
  end

  def profiles_with_revealed_emails
    profiles.where(id: revealed_ids)
  end

  def profiles_with_hidden_emails
    profiles.where.not(id: revealed_ids)
  end

  def download
    self.profiles
  end

  def purchase(params)
    return false unless check_md5_hash
    if params['sid'].to_i == 202864835 and params['li_0_uid'] == uid
      next_payment = subscription_expires.nil? ? Time.now + 1.month : subscription_expires + 1.month
      case params['li_0_price'].to_f
        when 9.0
          self.update(plan: '', subscription_expires: next_payment, calls_left: 0)
        when 39.0
          self.update(plan: 'Basic', subscription_expires: next_payment, calls_left: calls_left + 80)
        when 99.0
          self.update(plan: 'Advanced', subscription_expires: next_payment, calls_left: calls_left + 250)
      end
      return true
    end
    return false
  end

  def check_md5_hash
    true
  end

  def add_profiles(params)
    request = UserRequest.new(params)
    case request.source
      when :linkedin
        profiles = Profile.where(linkedin_id: [request.ids])
        profiles.each do |profile|
          self.profiles << profile unless self.profiles.include?(profile)
        end
      when :facebook
      when :twitter
    end
    self.save if changed?
  end

  def self.create_with_uid_and_email(uid, email)
    User.create(email: email,
                password: Devise.friendly_token[0, 20],
                uid: uid)
  end

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.find_by(email: data[:email])

    unless user
      user = User.create(name: data[:name],
                         email: data[:email],
                         password: Devise.friendly_token[0, 20],
                         image: data[:image],
                         uid: access_token[:uid])
    end
    user.update_with_omniauth(access_token) if user.image.nil?
    user
  end

  def update_with_omniauth(access_token)
    data = access_token.info
    update(name: data[:name],
           email: data[:email],
           password: Devise.friendly_token[0, 20],
           image: data[:image],
           uid: access_token[:uid])
  end

  def reveal_emails
    new_revealed = revealed_ids
    hidden_emails_size = profiles_with_hidden_emails.size
    self.update(progress: 0.0) if hidden_emails_size > 0
    profiles_with_hidden_emails.each_with_index do |profile, i|
      profile.get_emails_and_notes
      self.update(progress: ((i+1)/hidden_emails_size.to_f).round(4)*100)
      new_revealed << profile.id
    end
    self.update(revealed_ids: new_revealed, calls_left: calls_left - hidden_emails_size) if hidden_emails_size > 0
  end

  def export_profiles(options = {})
    columns = %w(name position photo location emails notes linkedin_url twitter_url facebook_url)
    CSV.generate(options) do |csv|
      csv << columns.map(&:capitalize)
      profiles.each do |profile|
        csv << profile.attributes.values_at(*columns)
      end
    end
  end

  protected
  def create_lists
    self.lists.create(name: 'Main', text:
        %{
Greetings {First Name},

I came across your profile investigating the Transportation & Logistics industry, where my team and I have built likeminded professionals several projects, specifically bespoke apps and software to tackle problems in Transportation / Supply Chain / Logistics, like fleet and warehouse management, reducing the middleman role in shipping, finding licensed carriers, cargo tracking, coordination and prediction of issues, and route planning. I thought you and {Company} may face some of these challenges too.

One of our recent projects allows shipping companies to identify and assess licensed carriers, reducing middlemen costs from 20% to 2-3%. 29,000 brokers and 17,000 shippers are currently using the app.
Our Courier Oversight Mobile App allows enhanced tracking, route planning and paperless solutions for startup companies. Since investing in this Magora application, the company has seen 300,000 users (59% daily) and 11,000,000 GB Pounds in revenue generated in over 3 years.

Magora.co.uk develop bespoke b2b apps from scratch, but we are always looking to identify issues that could be solved with software, so that we may help our clients to better manage their Transportation companies, increase sales and earn more money.

Do you have a few minutes either this week or next for a quick call to discuss this further? If so, just reply back here and let me know when the best time for you is.

Thnak you,
{My Name}
}
    )
  end
end