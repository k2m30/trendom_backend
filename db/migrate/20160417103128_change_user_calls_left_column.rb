class ChangeUserCallsLeftColumn < ActiveRecord::Migration
  def change
    remove_column :users, :calls_left
    add_column :users, :calls_left, :integer, default: 0
  end
end
