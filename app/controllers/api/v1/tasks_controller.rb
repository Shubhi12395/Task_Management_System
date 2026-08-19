class Api::V1::TasksController < ApplicationController
    def create
        task = Task.new(task_params)
        if task.save
            render json: { 
            message: 'Task created successfully', 
            task: { task_id: task.id, title:task.title, description: task.description, completed: task.completed, priority: task.priority, user_id: task.user_id, due_date: task.due_date} 
            }, status: :created
        else
            render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
        end 
    end
    def index
        
        @tasks = current_user.tasks
        render json: @tasks, status: :ok
    end
    def show
        task_params = params.expect(:id)
        
        @task = @current_user.tasks.find(task_params)
        
        render json: @task, status: :ok
    rescue ActiveRecord::RecordNotFound
        render json: { error: "Task not found" }, status: :not_found
    end
    def update
        @task = Task.find(params[:id])
        
        if @task.update(taskupdate_params)
            render json: 
            { message: 'Task updated successfully',
            task: @task }, status: :ok
        else
            render json: @task.errors, status: :unprocessable_entity
        end
    end
    def destroy
         @task = Task.find(params[:id])
        if @task.destroy
            render json: 
            { message: 'Task deleted successfully',
            task: @task }, status: :ok
        else
            render json:
            {message: 'task not found',
             task: @task.errors}, status: :unprocessable_entity
        end
        rescue ActiveRecord::RecordNotFound
        render json: { error: "Task not found" }, status: :not_found
    end
    private
    
    def task_params
        params.require(:task).permit(:title, :description, :completed, :priority, :user_id, :due_date)
    end  
    def taskupdate_params
        params.permit(:title, :description, :completed, :priority, :due_date)
    end
end

