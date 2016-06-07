class Campaign < ActiveRecord::Base
  belongs_to :user
  has_many :email_templates, through: :user

  serialize :profiles_ids

  def send_campaign

  end

  def profiles
    Profile.where(id: profiles_ids)
  end
end
