class CreateUsersProfiles < ActiveRecord::Migration
  def change
    create_table :profiles_users, id: false do |t|
      t.belongs_to :user, index: true
      t.belongs_to :profile, index: true
    end
  end
end
