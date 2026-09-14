ActiveAdmin.register Task do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :title, :description, :status, :due_date, :priority, :user_id, :completed_at, :project_id, :assignee_id, :creator_id, :parent_id
   # or
   #
   # permit_params do
   #   permitted = [:title, :description, :status, :due_date, :priority, :user_id]
   #   permitted << :other if params[:action] == 'create' && current_user.admin?
   #   permitted
   # end
   remove_filter :comments
end
