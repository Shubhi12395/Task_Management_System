class Project < ApplicationRecord
  acts_as_paranoid
  belongs_to :user
  has_many :tasks, dependent: :destroy
  enum :status, { not_started: 0, in_progress: 1, completed: 2 }
  validates :name, presence: true
  validates :description, presence: true, length: { minimum: 10 }
  validate :due_date_must_be_in_the_future
  def self.ransackable_associations(auth_object = nil)
    [ "user","tasks" ]
  end
  
  def self.ransackable_attributes(auth_object = nil)
    [ "status", "created_at", "description", "due_date", "id", "id_value", "name", "updated_at", "user_id"]
  end

private

  def due_date_must_be_in_the_future
    if due_date_changed? && due_date.present? && due_date < Time.zone.today
      errors.add(:due_date, "can't be in the past")
    end
  end
end