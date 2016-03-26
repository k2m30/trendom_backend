class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :name
      t.string :position
      t.string :industry
      t.string :location
      t.string :email, index: true
      t.text :notes

      t.string :linkedin_url
      t.string :twitter_url
      t.string :facebook_url

      t.integer :linkedin_id, index: true
      t.integer :twitter_id, index: true
      t.integer :facebook_id, index: true

      t.belongs_to :user

      t.timestamps
    end

    create_table :users do |t|
      t.string :oauth, index: true
      t.string :email, index: true
      t.string :name
      t.string :plan
      t.datetime :subscription_expires
      t.string :calls_left

      t.timestamps
    end

    create_table :people_users, id: false do |t|
      t.belongs_to :user, index: true
      t.belongs_to :people, index: true
    end
  end
end
