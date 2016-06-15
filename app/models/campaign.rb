require 'gmail'

class Campaign < ActiveRecord::Base
  belongs_to :user
  has_many :email_templates, through: :user

  serialize :profiles_ids

  def send_out
    profiles.each do |profile|
      if Rails.env.test? #or Rails.env.development?
        SendEmailJob.set(queue: 'test').perform_now(profile.id, id, user.email, user.tkn, user.name)
      else
        SendEmailJob.set(queue: user.name.to_sym).perform_later(profile.id, id, user.email, user.tkn, user.name)
      end
    end
  end

  def profiles
    Profile.where(id: profiles_ids)
  end
end
