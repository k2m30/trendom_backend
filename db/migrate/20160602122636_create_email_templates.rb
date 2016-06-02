class CreateEmailTemplates < ActiveRecord::Migration
  def change
    create_table :email_templates do |t|
      t.string :name
      t.text :text
      t.belongs_to :user

      t.timestamps null: false
    end
  end
end
