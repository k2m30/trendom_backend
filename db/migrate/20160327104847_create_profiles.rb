class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :name
      t.string :position
      t.string :photo
      t.string :location
      t.string :email, index: true
      t.text :notes

      t.string :linkedin_url
      t.string :twitter_url
      t.string :facebook_url

      t.integer :linkedin_id, index: true
      t.integer :twitter_id, index: true
      t.integer :facebook_id, index: true
      t.integer :emails_available
      t.timestamps

    end
  end
end
