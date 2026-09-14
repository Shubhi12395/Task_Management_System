require 'rails_helper'

RSpec.describe "Api::V1::ProjectPolicy", type: :policy do
  let(:user) { create(:user) }
  let(:project) { create(:project, user: user) }
  let(:policy) { Api::V1::ProjectPolicy.new(user, project) }

  context "being the owner of the resource" do
    it "allows viewing the project" do
      expect(policy.show?).to be true
    end

    it "allows creating a project" do
      expect(policy.create?).to be true
    end

    it "allows updating the project" do
      expect(policy.update?).to be true
    end

    it "allows deleting the project" do
      expect(policy.destroy?).to be true
    end
  end
end
