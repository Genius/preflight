class CreateChecklistItems < ActiveRecord::Migration[4.2]
  def change
    create_table :checklist_items do |t|
      t.string :name, null: false
      t.belongs_to :checklist, null: false

      t.timestamps null: false
    end
  end
end
