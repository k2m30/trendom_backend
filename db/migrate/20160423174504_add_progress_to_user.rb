class AddProgressToUser < ActiveRecord::Migration
  def change
    add_column :users, :progress, :float, default: 0.0
  end
end
