require 'gmail'

class Campaign < ActiveRecord::Base
  belongs_to :user
  has_many :email_templates, through: :user

  serialize :profiles_ids

  def send_out
    size = profiles.size
    gmail = Gmail.connect(:xoauth2, 'email@domain.com', user.tkn)
    profiles.each_with_index do |profile, i|
      if Rails.env.production?
        gmail.deliver do
          to profile.emails.first
          subject "Having fun in Puerto Rico!"
          text_part do
            body profile.apply_template(email_template_id)
          end
        end
      else
        sleep 0.3
      end
      self.update(progress: ((i+1).to_f/size.to_f*100.0).round(2))
    end
    self.update(sent: true)
  end

  def profiles
    Profile.where(id: profiles_ids)
  end
end
