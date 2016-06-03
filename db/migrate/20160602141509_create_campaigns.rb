class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :name
      t.boolean :sent, default: false
      t.datetime :date_sent
      t.text :profiles_ids, default: []
      t.integer :email_template_id, null: false

      t.belongs_to :user

      t.timestamps null: false
    end

    add_column :users, :campaigns_sent_ids, :text, default: []
  end
end
