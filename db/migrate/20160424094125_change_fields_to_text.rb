class ChangeFieldsToText < ActiveRecord::Migration
  def change
    remove_column :users, :revealed_ids
    add_column :users, :revealed_ids, :text, default: []
  end
end
