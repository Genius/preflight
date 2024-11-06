# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = User.create(
  email: 'tech-team+preflight@genius.com',
  password: 'preflight',
  admin: true
)

github_repository = GithubRepository.create(
  github_id: 1, 
  github_full_name: 'Repository',
  github_owner_type: 'Organization',
  github_url: 'https://github.com/Genius/Rap-Genius'
)

checklist = Checklist.create(
  name: 'Check filename',
  created_by: user,
  github_repository: github_repository
)

checklist_item = ChecklistItem.create(
  name: 'Did you confirm the changes?',
  checklist: checklist,
  created_by: user
)