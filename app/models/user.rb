class User < ApplicationRecord
    has_many :tasks
    has_one_attached :avatar
    validates :name, presence: true
    validates :email, presence: true,uniqueness: true
    has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
end
