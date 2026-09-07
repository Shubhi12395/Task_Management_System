class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :status, :due_date, :user_id
end
