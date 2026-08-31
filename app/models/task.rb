class Task < ApplicationRecord
  acts_as_paranoid
  belongs_to :user 
  before_update :prevent_update
  
  validates :title, presence: true
  validates :description,presence: true, length: { minimum: 10 }
  
  validates :completed, inclusion: { in: [true, false], message: "%{value} is not a valid completion" }
  validates :priority, inclusion: { in: %w(high medium low), message: "%{value} is not a valid priority" }
  
   validate :due_date_must_be_in_the_future
  
  
  def self.ransackable_associations(auth_object = nil)
    ["user"]
  end
  
  def self.ransackable_attributes(auth_object = nil)
    ["completed", "created_at", "description", "due_date", "id", "id_value", "priority", "title", "updated_at", "user_id"]
  end
  
  private
  
  def due_date_must_be_in_the_future
    if due_date < Time.zone.today
      errors.add(:due_date, "can't be in the past")
    end
  end
  
  def prevent_update
     if due_date_in_database.present? && due_date_in_database < Date.current
    errors.add(:base, "This task cannot be updated as due date is passed.")
    throw(:abort) 
     end
  end
end
