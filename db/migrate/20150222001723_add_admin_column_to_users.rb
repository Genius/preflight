class AddAdminColumnToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :admin, :boolean, null: false, default: false
  end
end
