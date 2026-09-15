# spec/policies/api/v1/task_policy_spec.rb
require 'rails_helper'

RSpec.describe "Api::V1::TaskPolicy", type: :policy do
  let(:user) { create(:user) }
  let(:task) { create(:task) }
  let(:policy) { Api::V1::TaskPolicy.new(user, task) }

  context "when evaluating global task action permissions" do
    it "allows viewing a task" do
      expect(policy.show?).to be true
    end

    it "allows creating a task" do
      expect(policy.create?).to be true
    end

    it "allows updating a task" do
      expect(policy.update?).to be true
    end

    it "allows deleting a task" do
      expect(policy.destroy?).to be true
    end

    it "allows searching for tasks" do
      expect(policy.search?).to be true
    end

    it "allows checking overdue tasks" do
      expect(policy.overdue?).to be true
    end
  end
end
