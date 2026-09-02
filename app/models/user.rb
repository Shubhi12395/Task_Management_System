class User < ApplicationRecord
  acts_as_paranoid
  has_many :tasks, dependent: :destroy
  has_one_attached :avatar
  validates :name, presence: true
  validates :email, presence: true,uniqueness: true
  has_secure_password
  validates :password, length: { minimum: 6 }, allow_nil: true
  def self.ransackable_associations(auth_object = nil)
    ["tasks", "avatar_attachment", "avatar_blob"]
  end
  def self.ransackable_attributes(auth_object = nil)
    ["id", "id_value", "name", "email", "created_at", "updated_at"]
  end
end
