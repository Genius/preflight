class ChangeAppliedChecklistPullRequestIdIntegerToBigInt < ActiveRecord::Migration[5.2]
  def up
    change_column :applied_checklists, :github_pull_request_id, :bigint
  end

  def down
    change_column :applied_checklists, :github_pull_request_id, :integer
  end
end
