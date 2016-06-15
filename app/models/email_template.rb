class EmailTemplate < ActiveRecord::Base
  belongs_to :user

  before_destroy :clean_campaigns

  def clone
    new_attributes = attributes
    new_attributes.delete('id')
    EmailTemplate.create(new_attributes)
  end

  def clean_campaigns
    campaign = user.campaigns.find_by(email_template_id: id)
    campaign.destroy if campaign.present?
  end
end
