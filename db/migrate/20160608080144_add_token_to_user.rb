class AddTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :tkn, :string
    add_column :users, :expires_at, :integer
  end
end
