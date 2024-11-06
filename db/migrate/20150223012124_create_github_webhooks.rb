class CreateGithubWebhooks < ActiveRecord::Migration[4.2]
  def change
    create_table :github_webhooks do |t|
      t.integer :github_id, null: false
      t.belongs_to :github_repository, null: false
      t.belongs_to :created_by, null: false

      t.timestamps null: false
    end

    add_index :github_webhooks, :github_id
  end
end
