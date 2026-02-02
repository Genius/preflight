IDENTITY_TEMPLATE = File.read(Rails.root.join('spec', 'data', 'github_omniauth_data.yml'))

FactoryBot.define do
  factory :identity do
    provider { 'github' }
    sequence(:uid)
    user

    omniauth_data do
      YAML.unsafe_load(ERB.new(IDENTITY_TEMPLATE).result(binding))
    end
  end
end
