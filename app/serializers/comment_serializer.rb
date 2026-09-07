class CommentSerializer < ActiveModel::Serializer
  attributes :content, :commentable_type, :commentable_id
end
