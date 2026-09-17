class User < ApplicationRecord
  acts_as_paranoid
  has_secure_password
  has_many :projects, dependent: :destroy
  has_many :tasks, through: :projects
  has_one_attached :avatar
  has_many :assigned_tasks, class_name: "Task", foreign_key: "assignee_id", dependent: :nullify
  has_many :comments, as: :commentable, dependent: :destroy
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, allow_nil: true

  # validates :password, length: { minimum: 6 }, allow_nil: true
  def self.ransackable_associations(auth_object = nil)
    [ "tasks", "avatar_attachment", "avatar_blob", "projects", "comments" ]
  end
  def self.ransackable_attributes(auth_object = nil)
    [ "id", "id_value", "name", "email", "created_at", "updated_at" ]
  end
end
