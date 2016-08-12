require 'csv'
class User < ActiveRecord::Base
  devise :database_authenticatable, :trackable, :omniauthable, omniauth_providers: [:google_oauth2]

  serialize :revealed_ids
  serialize :campaigns_sent_ids

  has_many :email_templates, dependent: :delete_all
  has_many :campaigns, dependent: :delete_all

  has_and_belongs_to_many :profiles

  after_create :create_email_templates

  def active?
    active = (calls_left > 0 and Time.now < subscription_expires)
    update(plan: 'Free') unless active
    active
  end

  # def enough_calls?
  #   calls_left >= profiles_with_hidden_emails.size
  # end

  def profiles_with_revealed_emails
    profiles.where(id: revealed_ids)
  end

  def profiles_with_hidden_emails
    profiles.where.not(id: revealed_ids)
  end

  def profiles_not_contacted
    ids = campaigns.where(sent: true).pluck(:profiles_ids)
    profiles_with_revealed_emails.where.not(id: ids)
  end

  def profiles_not_in_campaigns
    ids = campaigns.pluck(:profiles_ids)
    profiles.where.not(id: ids.flatten)
  end

  # def download
  #   self.profiles
  # end

  def purchase(params)
    return false unless check_md5_hash
    if params['sid'].to_i == 202864835 and params['li_0_uid'] == uid
      next_payment = subscription_expires.nil? ? Time.now + 1.month : subscription_expires + 1.month
      case params['li_0_price'].to_f
        when 39.0
          self.update(plan: 'Light', subscription_expires: next_payment, calls_left: calls_left + 80)
        when 99.0
          self.update(plan: 'Standard', subscription_expires: next_payment, calls_left: calls_left + 250)
        when 279.0
          self.update(plan: 'Advanced', subscription_expires: next_payment, calls_left: calls_left + 2000)
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
        profiles = Profile.where(linkedin_id: request.ids)
        profiles.each do |profile|
          self.profiles << profile unless self.profiles.include?(profile)
        end
      when :facebook
      when :twitter
    end
    work_size = reveal_emails
    self.save if changed?
    work_size
  end

  def self.create_with_uid_and_email(uid, email)
    User.create(email: email,
                password: Devise.friendly_token[0, 20],
                uid: uid,
                calls_left: 10,
                plan: 'Free',
                subscription_expires: Time.now)
  end

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.find_by(email: data[:email])

    unless user
      user = User.create(name: data[:name],
                         email: data[:email],
                         password: Devise.friendly_token[0, 20],
                         image: data[:image],
                         calls_left: 10,
                         plan: 'Free',
                         uid: access_token[:uid],
                         subscription_expires: Time.now)
    end
    user.update_with_omniauth(access_token) if user.image.nil?
    user.update(tkn: access_token.credentials.token, expires_at: access_token.credentials.expires_at)
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
    work_size = [profiles_with_hidden_emails.size, calls_left].min
    self.update(progress: 0.0) #if hidden_emails_size > 0
    profiles_with_hidden_emails[0..work_size-1].each do |profile|
      if Rails.env.test?
        RevealEmailJob.set(queue: :test).perform_now(id, profile.id, (1/work_size.to_f*100.0).round(2))
      else
        RevealEmailJob.set(queue: name.to_sym).perform_later(id, profile.id, (1/work_size.to_f*100.0).round(2))
      end
    end
    work_size
  end

  def export_profiles(options = {})
    columns = %w(name position photo location emails notes linkedin_url twitter_url facebook_url)
    CSV.generate(options) do |csv|
      csv << columns.map(&:capitalize)
      profiles_with_revealed_emails.each do |profile|
        csv << profile.attributes.values_at(*columns)
      end
    end
  end

  def plan?(p)
    plan.downcase == p.downcase
  end

  protected
  def create_email_templates
    self.email_templates.create(name: 'Main', text:
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
    self.email_templates.create(name: 'Secondary', text:
        %{
Hello {First Name},

I came across your profile investigating the Transportation & Logistics industry, where my team and I have built likeminded professionals several projects, specifically bespoke apps and software to tackle problems in Transportation / Supply Chain / Logistics, like fleet and warehouse management, reducing the middleman role in shipping, finding licensed carriers, cargo tracking, coordination and prediction of issues, and route planning. I thought you and {Company} may face some of these challenges too.

Do you have a few minutes either this week or next for a quick call to discuss this further? If so, just reply back here and let me know when the best time for you is.

Thnak you,
{My Name}
}
    )
  end
end