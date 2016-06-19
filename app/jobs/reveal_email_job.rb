class RevealEmailJob < ActiveJob::Base
  queue_as :default

  def perform(*args)

  end
end
