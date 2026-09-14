class TaskSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :status, :priority, :due_date, :completed_at, :project_id, :parent_id, :assignee_id, :creator_id
end
