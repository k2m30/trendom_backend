class AddFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :card_holder_name, :string
    add_column :users, :street_address, :string
    add_column :users, :street_address2, :string
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :zip, :string
    add_column :users, :country, :string
    add_column :users, :billing_email, :string
    add_column :users, :phone, :string
    add_column :users, :card_number, :string
  end
end
