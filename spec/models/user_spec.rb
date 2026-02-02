require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'serializes omniauth data' do
    subject { create(:user) }

    its(:github_profile_url) { should be_present }
    its(:avatar_url) { should be_present }
  end
end
