class RevealEmailJob < ActiveJob::Base
  queue_as :default

  def perform(user_id, profile_id, increment)
    user = User.find(user_id)
    if user.revealed_ids.include?(profile_id)
      user.update(progress: (user.progress + increment).round(2))
      return
    end

    profile = Profile.find(profile_id)
    profile.get_emails
    profile.reload
    update_hash = {progress: (user.progress + increment).round(2), revealed_ids: user.revealed_ids << profile_id}
    update_hash[:calls_left] = user.calls_left-1 unless profile.emails.empty?
    user.update(update_hash)
  end
end
