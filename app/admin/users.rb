ActiveAdmin.register User do
  actions :all 
  index do
    selectable_column
    id_column
    column :name
    column :email
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :email
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  form do |f|
    f.inputs 'User Details' do
      f.input :name
      f.input :email
      f.input :password              
    end
    f.actions
  end
  permit_params :name, :email, :password
  
  controller do
    def update
      if params[:user][:password].blank?
        params[:user].delete(:password)
      end
      super
    end
    
  end
  
  
  # or
  #
  # permit_params do
  #   permitted = [:name, :email, :password_digest]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  filter :id
  filter :name
  filter :email
  filter :created_at
  filter :updated_at
end
