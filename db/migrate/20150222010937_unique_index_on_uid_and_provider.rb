class UniqueIndexOnUidAndProvider < ActiveRecord::Migration[4.2]
  def change
    add_index :identities, [:uid, :provider], unique: true
  end
end
