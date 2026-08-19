class Task < ApplicationRecord
  belongs_to :user 
  
  validates :title, presence: true
  validates :description, length: { minimum: 10 }
  
  validates :completed, inclusion: { in: [true, false], message: "%{value} is not a valid completion" }
  
  validates :priority, inclusion: { in: %w(high medium low), message: "%{value} is not a valid priority" }
  
  validate :due_date_must_be_in_the_future
  
  private
  
  def due_date_must_be_in_the_future
    if due_date.present? && due_date < Time.zone.today
      errors.add(:due_date, "can't be in the past")
    end
  end
end
