require 'gmail'

class SendEmailJob < ActiveJob::Base
  queue_as :default

  def perform(profile_id, campaign_id, user_email, token)
    profile = Profile.find(profile_id)
    campaign = Campaign.find(campaign_id)
    if Rails.env.production? or Rails.env.development?
      gmail = Gmail.connect(:xoauth2, user_email, token)
      gmail.deliver do
        to profile.emails.first
        subject campaign.subject
        text_part do
          body profile.apply_template(email_template_id)
        end
      end
      sleep rand(60..80)
    else
      sleep 0.3
    end
    progress = campaign.progress
    size = campaign.profiles_ids.size.to_f
    campaign.update(progress: progress + (1.0/size*100.0).round(2))
    campaign.update(sent: true) if campaign.progress >= 100.0
  end
end
