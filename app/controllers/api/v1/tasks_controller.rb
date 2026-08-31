class Api::V1::TasksController < ApiController
  def create
    task = current_user.tasks.new(task_params)
    if task.save
      render json: { 
      message: 'Task created successfully', task: task 
      }, status: :created
    else
      render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
    end 
  end
  
  def index
    @pagy, @tasks = pagy(current_user.tasks)
    if params[:sort] == 'priority'
      # @tasks =@tasks.in_order_of(:priority, %w(high medium low))
      @tasks=@tasks.sort_by { |task| ['high', 'medium', 'low'].index(task.priority) }
    end
    if params[:sort] == 'due_date'
      @tasks=@tasks.order(due_date: :asc)
    end
    render json: { tasks: @tasks, each_serializer: TaskSerializer, meta: pagy_metadata(@pagy) }, status: :ok
  end
  
  def show
    task = @current_user.tasks
    if params[:title]
      @task=task.find_by(title: params[:title])
      
    else
      @task=task.find(params[:id])
    end
    render json: @task, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Task not found" }, status: :not_found
  end
  
  def update

    task = @current_user.tasks
    @task = task.find(params[:id])
    
    if @task.update(task_params)
      render json: 
      { message: 'Task updated successfully',
      task: @task }, status: :ok
    else
      render json: @task.errors, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Task not found" }, status: :not_found
  end
  
  def destroy
    task = @current_user.tasks
    @task = task.find(params[:id])
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
    params.require(:task).permit(:title, :description, :completed,:priority, :due_date)
  end  
end

