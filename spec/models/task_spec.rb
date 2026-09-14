require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'Validations' do
    it 'is valid with valid factory attributes' do
      task = build(:task)
      expect(task).to be_valid
    end

    it 'is invalid without a title' do
      task = build(:task, title: nil)
      expect(task).not_to be_valid
      expect(task.errors[:title]).to include("can't be blank")
    end

    it 'is invalid with a description shorter than 10 characters' do
      task = build(:task, description: 'Short')
      expect(task).not_to be_valid
      expect(task.errors[:description]).to include("is too short (minimum is 10 characters)")
    end



    it 'is valid with high, medium, or low priorities' do
      expect(build(:task, priority: 'high')).to be_valid
      expect(build(:task, priority: 'medium')).to be_valid
      expect(build(:task, priority: 'low')).to be_valid
    end

    it 'is invalid with an incorrect priority value' do
      task = build(:task, priority: 'urgent')
      expect(task).not_to be_valid
      expect(task.errors[:priority]).to include("urgent is not a valid priority")
    end

    it 'is valid when due_date is in the future' do
      task = build(:task, due_date: Date.tomorrow)
      expect(task).to be_valid
    end

    it 'is valid when due_date is today' do
      task = build(:task, due_date: Date.today)
      expect(task).to be_valid
    end

    it 'is invalid when due_date is in the past' do
      task = build(:task, due_date: Date.yesterday)
      expect(task).not_to be_valid
      expect(task.errors[:due_date]).to include("can't be in the past")
    end
  end

  describe 'Associations' do
    it 'belongs to a project' do
      association = Task.reflect_on_association(:project)
      expect(association.macro).to eq(:belongs_to)
    end
  end
  describe 'enums' do
    it "defines status enum" do
      expect(Task.statuses.keys).to include("todo", "in_progress", "done")
    end

    it "maps statuses to the correct integers" do
      expect(Task.statuses).to eq({ "todo" => 0, "in_progress" => 1, "done" => 2 })
    end
  end
end
