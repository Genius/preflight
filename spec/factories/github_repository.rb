FactoryBot.define do
  factory :github_repository do
    github_id { Random.random_number(1...8_000_000) }
    github_full_name { "#{Faker::Internet.user_name}/#{Faker::Adjective.positive}" }
    github_url { "https://github.com/#{github_full_name}" }
    github_owner_type { "Organization" }
  end
end
