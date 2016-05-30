class CreateLists < ActiveRecord::Migration
  def change
    drop_table :profiles_users do |t|
    end

    create_table :lists do |t|
      t.string :name
      t.text :text
      t.belongs_to :user

      t.timestamps null: false
    end

    create_join_table :lists, :profiles do |t|
      t.index :list_id
      t.index :profile_id
    end

  end
end
