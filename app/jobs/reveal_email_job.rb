class RevealEmailJob < ActiveJob::Base
  queue_as :default

  def perform(user_id, profile_id, increment)
    user = User.find(user_id)
    return if user.revealed_ids.include?(profile_id)

    profile = Profile.find(profile_id)
    profile.get_emails
    user.update(progress: (user.progress + increment).round(2), revealed_ids: user.revealed_ids << profile_id, calls_left: user.calls_left-1)
  end
end
