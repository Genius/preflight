class AddDataclipsSkillChecklist < ActiveRecord::Migration[7.2]
  def up
    repo = GithubRepository.find_by!(github_full_name: "Genius/Rap-Genius")
    admin = User.find_by!(admin: true)

    checklist = Checklist.create!(
      name: "Dataclips Skill Update",
      github_repository: repo,
      created_by: admin,
      last_updated_by: admin,
      with_file_matching_pattern: "db/development_structure\\.sql",
    )

    ChecklistItem.create!(
      checklist: checklist,
      name: "If `db/development_structure.sql` has changed, check with the product team to confirm whether the dataclips skill needs to be updated.",
      created_by: admin,
    )
  end

  def down
    repo = GithubRepository.find_by(github_full_name: "Genius/Rap-Genius")
    return unless repo

    Checklist.where(
      github_repository: repo,
      name: "Dataclips Skill Update",
    ).destroy_all
  end
end
