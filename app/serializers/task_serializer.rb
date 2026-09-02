class TaskSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :completed, :priority, :due_date 
  
end
