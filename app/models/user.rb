class User < ActiveRecord::Base
  has_and_belongs_to_many :people

  def download
    self.people
  end
end