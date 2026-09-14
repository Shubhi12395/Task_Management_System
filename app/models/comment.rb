class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true

  def self.ransackable_associations(auth_object = nil)
    [ "user", "task" ]
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "content", "created_at", "commentable_type", "commentable_id", "updated_at" ]
  end
end
