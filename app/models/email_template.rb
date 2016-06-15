class EmailTemplate < ActiveRecord::Base
  belongs_to :user

  def clone
    new_attributes = attributes
    new_attributes.delete('id')
    EmailTemplate.create(new_attributes)
  end
end
