require 'rails_helper'

RSpec.describe Project, type: :model do
  describe 'Validations' do
    it 'is valid with valid factory attributes' do
      project= build(:project)
      expect(project).to be_valid
    end

    it 'is invalid without a name' do
      project = build(:project, name: nil)
      expect(project).not_to be_valid
      expect(project.errors[:name]).to include("can't be blank")
    end
    it 'is invalid without a description' do
      project = build(:project, description: nil)
      expect(project).not_to be_valid
      expect(project.errors[:description]).to include("can't be blank")
    end
    it 'is invalid with a description shorter than 10 characters' do
      project = build(:project, description: 'Short')
      expect(project).not_to be_valid
      expect(project.errors[:description]).to include("is too short (minimum is 10 characters)")
    end

    it 'is valid when due_date is in the future' do
      project = build(:project, due_date: Date.tomorrow)
      expect(project).to be_valid
    end

    it 'is valid when due_date is today' do
      project = build(:project, due_date: Date.today)
      expect(project).to be_valid
    end

    it 'is invalid when due_date is in the past' do
      project = build(:project, due_date: Date.yesterday)
      expect(project).not_to be_valid
      expect(project.errors[:due_date]).to include("can't be in the past")
    end
  end

  describe 'Associations' do
    it 'belongs to a user' do
      association = Project.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end
  end
  describe 'enums' do
    it "defines status enum" do
      expect(Project.statuses.keys).to include("not_started", "in_progress", "completed")
    end

    it "maps statuses to the correct integers" do
      expect(Project.statuses).to eq({ "not_started" => 0, "in_progress" => 1, "completed" => 2 })
    end
  end
end
