# frozen_string_literal: true
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }
  
  content title: proc { I18n.t("active_admin.dashboard") } do
    # div class: "blank_slate_container", id: "dashboard_default_message" do
    #   span class: "blank_slate" do
    #     span I18n.t("active_admin.dashboard_welcome.welcome")
    #     small I18n.t("active_admin.dashboard_welcome.call_to_action")
    #   end
    # end
    
    # Here is an example of a simple dashboard with columns and panels.
    
    columns do
      column do
        panel "total user" do
          User.count
        end
      end
      
      column do
        panel "total tasks" do
          Task.count
        end
      end
      column do
        panel "completed task" do
          Task.where(completed: true).count
        end
      end
      column do
        panel "overdue task" do
          Task.where("due_date<?",Date.current).count
        end
      end
    end
    columns do
      column do
        panel "Recent Users" do
          table_for User.order(created_at: :desc).limit(5) do
            column :id
            column :name
            column :email
            column :created_at
            column :failed_attempts
          end
        end
      end
      
      column do
        panel "Recent Tasks" do
          table_for Task.order(created_at: :desc).limit(5) do
            column :id
            column :title
            column :description
            column :priority
            column :user_id
            column :completed
            column :due_date
            
          end
        end
      end
    end
    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
  end # content
end
