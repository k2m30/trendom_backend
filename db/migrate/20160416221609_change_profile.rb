class ChangeProfile < ActiveRecord::Migration
  def change
    rename_column :profiles, :email, :emails
  end
end
