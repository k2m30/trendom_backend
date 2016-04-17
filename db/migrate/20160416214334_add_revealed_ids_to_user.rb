class AddRevealedIdsToUser < ActiveRecord::Migration
  def change
    add_column :users, :revealed_ids, :string, default: []
  end
end
