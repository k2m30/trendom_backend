class GetEmailsAvailableJob < ActiveJob::Base
  queue_as :pipl_api

  def perform(*args)
    # Do something later
  end
end
