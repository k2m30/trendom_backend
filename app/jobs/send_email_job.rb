require 'gmail'

class SendEmailJob < ActiveJob::Base
  queue_as :default

  def perform(profile_id, campaign_id, user_email, token, user_name)
    begin
      profile = Profile.find(profile_id)
      campaign = Campaign.find(campaign_id)
      if Rails.env.production? or Rails.env.development?
        gmail = Gmail.connect(:xoauth2, user_email, token)
        email = gmail.compose do
          to profile.emails.first
          subject campaign.subject
          text_part do
            body profile.apply_template(campaign.email_template_id)
          end
          from user_name if user_name.present?
        end
        email.deliver!
        sleep rand(60..80)
      else

      end
      progress = campaign.progress
      size = campaign.profiles_ids.size.to_f
      campaign.update(progress: progress + (1.0/size*100.0).round(2))
      campaign.update(sent: true) if campaign.progress >= 100.0
    rescue => e
      logger.error [user_name, profile_id]
      logger.error e.message
      logger.error pp e.backtrace[0..4]
    end
  end
end
