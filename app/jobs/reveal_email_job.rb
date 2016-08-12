class RevealEmailJob < ActiveJob::Base
  queue_as :default

  def perform(user_id, profile_id, increment)
    user = User.find(user_id)

    if user.calls_left.zero?
      return
    end

    if user.revealed_ids.include?(profile_id)
      sql = "UPDATE users SET progress = progress + #{increment} WHERE id = #{user_id};"
      ActiveRecord::Base.connection.execute(sql)
      return
    end

    profile = Profile.find(profile_id)
    profile.with_lock do
      profile.get_emails
    end

    sql = "UPDATE users SET calls_left = calls_left - 1, progress = progress + #{increment}, revealed_ids = regexp_replace(revealed_ids, ' \\[\\]', '') || '- #{profile_id}\n' WHERE id = #{user_id};"
    ActiveRecord::Base.connection.execute(sql)
  end
end
