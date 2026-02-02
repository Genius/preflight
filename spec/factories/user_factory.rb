FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.password }

    after(:create) do |user|
      create(:identity, user: user)
    end
  end
end
