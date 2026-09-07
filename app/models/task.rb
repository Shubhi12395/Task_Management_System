class Task < ApplicationRecord
  acts_as_paranoid
  has_many :comments, as: :commentable, dependent: :destroy
  belongs_to :project
  belongs_to :assignee, class_name: "User",optional: true
  belongs_to :creator, class_name: "User",foreign_key: :creator_id
  scope :duetoday, -> { where(due_date: Date.current) }
  scope :overdue, -> { where("tasks.due_date<?", Date.current) }
  scope :pending, -> { where(status: 0..1) }
  scope :by_priority, -> { in_order_of(:priority, %w(high medium low)) }
  enum :status, { todo: 0, in_progress: 1, done: 2 }
  validates :title, presence: true
  validates :description, presence: true, length: { minimum: 10 }
  validates :priority, inclusion: { in: %w[high medium low], message: "%{value} is not a valid priority" }
  validate :due_date_must_be_in_the_future


  def self.ransackable_associations(auth_object = nil)
    [ "user" , "project","comments"]
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "status", "created_at", "description", "due_date", "id", "id_value", "priority", "title", "updated_at", "user_id" ,"completed_at","project_id","assignee_id","creator_id"]
  end

  private

  def due_date_must_be_in_the_future
    if due_date_changed? && due_date.present? && due_date < Time.zone.today
      errors.add(:due_date, "can't be in the past")
    end
  end
end
