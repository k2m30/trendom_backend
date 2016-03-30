class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :rememberable, :trackable, :omniauthable, :omniauth_providers => [:google_oauth2]

  has_and_belongs_to_many :profiles

  def download
    self.profiles
  end

  def self.from_omniauth(access_token)
    data = access_token.info

    user = User.where(:email => data[:email]).first

    unless user
      user = User.create(name: data[:name],
                         email: data[:email],
                         password: Devise.friendly_token[0, 20],
                         image: data[:image],
                         uid: access_token[:uid]
      )
    end
    user
  end
end