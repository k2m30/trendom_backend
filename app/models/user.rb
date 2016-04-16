require 'csv'
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :trackable, :omniauthable, :omniauth_providers => [:google_oauth2]

  has_and_belongs_to_many :profiles

  def active?
    false
  end

  def download
    self.profiles
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

  def export_profiles(options = {})
    columns = %w(name position photo location email notes linkedin_url twitter_url facebook_url linkedin_id twitter_id facebook_id)
    CSV.generate(options) do |csv|
      csv << columns.map(&:capitalize)
      profiles.each do |profile|
        csv << profile.attributes.values_at(*columns)
      end
    end
  end
end