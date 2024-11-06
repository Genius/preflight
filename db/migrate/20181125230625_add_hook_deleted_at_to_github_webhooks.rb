class AddHookDeletedAtToGithubWebhooks < ActiveRecord::Migration[4.2]
  def change
    add_column :github_webhooks, :hook_deleted_at, :datetime
  end
end
