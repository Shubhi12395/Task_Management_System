class Api::V1::TasksController < ApiController
  def create
    task = current_user.tasks.new(task_params)
    task.creator_id=current_user.id
    if task.save
      render json: {
      message: "Task created successfully", task: TaskSerializer.new(task)
      }, status: :created
    else
      render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def index
    @pagy, @tasks = pagy(current_user.tasks.includes(:project))
    serialized_tasks = ActiveModelSerializers::SerializableResource.new(@tasks, each_serializer: TaskSerializer)
    render json: { tasks: serialized_tasks, meta: pagy_metadata(@pagy) }, status: :ok
  end
  
  def show
    @task=@current_user.tasks.find(params[:id])
    render json: @task, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Task not found" }, status: :not_found
  end
  
  def sort
    @pagy, @tasks = pagy(current_user.tasks.includes(:project))
    if params[:sort] == "priority"
      # @tasks =@tasks.in_order_of(:priority, %w(high medium low))
      @tasks=@tasks.sort_by { |task| [ "high", "medium", "low" ].index(task.priority) }
    end
    if params[:sort] == "due_date"
      @tasks=@tasks.order(due_date: :asc)
    end
    serialized_tasks = ActiveModelSerializers::SerializableResource.new(@tasks, each_serializer: TaskSerializer)
    render json: { tasks: serialized_tasks, meta: pagy_metadata(@pagy) }, status: :ok
  end
  def search
    @task=@current_user.tasks
    @task = @task.where("title ILIKE ? OR description ILIKE ?", "#{params[:search]}%", "#{params[:search]}%")
    if @task.empty?
      render json: { error: "Task not found" }, status: :not_found
    else
      render json: @task, status: :ok
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Task not found" }, status: :not_found
  end
  def update
    task = @current_user.tasks
    @task = task.find(params[:id])
    
    if @task.update(task_params)
      render json:
      { message: "Task updated successfully",
      task: TaskSerializer.new(@task) }, status: :ok
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Task not found" }, status: :not_found
  end
  
  def update_all
    tasks= @current_user.tasks
    ids=params[:_json]
    pid = tasks.where(id: ids).pluck(:id)
    nid= ids - pid
    tasks= tasks.where(id: pid)
    tasks.update_all(status: 2)
    serialized_tasks = ActiveModelSerializers::SerializableResource.new(tasks, each_serializer: TaskSerializer)
    render json: { message: "Tasks updated successfully", tasks: serialized_tasks, not_found_tasks: nid }, status: :ok
  end
  
  def destroy
    task = @current_user.tasks
    @task = task.find(params[:id])
    if @task.destroy
      render json:
      { message: "Task deleted successfully",
      task: TaskSerializer.new(@task) }, status: :ok
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Task not found" }, status: :not_found
  end
  
  def destroy_all
    tasks=@current_user.tasks
    ids=params[:_json]
    pid = tasks.where(id: ids).pluck(:id)
    nid= ids - pid
    tasks= tasks.where(id: pid)
    tasks.destroy_all
    render json: { message: "Tasks deleted successfully", not_found_tasks: nid }, status: :ok
    
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Task not found" }, status: :not_found
  end
  
  def duetoday
    @pagy, @tasks = pagy(current_user.tasks.duetoday.includes(:user))
    if @tasks.empty?
      render json: { error: "No tasks due today" }, status: :not_found
    else
      serialized_tasks = ActiveModelSerializers::SerializableResource.new(@tasks, each_serializer: TaskSerializer)
      render json: { tasks: serialized_tasks, meta: pagy_metadata(@pagy) }, status: :ok
    end
  end

  def overdue
    @pagy, @tasks = pagy(current_user.tasks.overdue.includes(:user))
    if @tasks.empty?
      render json: { error: "No overdue tasks" }, status: :not_found
    else
      serialized_tasks = ActiveModelSerializers::SerializableResource.new(@tasks, each_serializer: TaskSerializer)
      render json: { tasks: serialized_tasks, meta: pagy_metadata(@pagy) }, status: :ok
    end
  end
  
  def pending
    @pagy, @tasks = pagy(current_user.tasks.pending.includes(:project))
    if @tasks.empty?
      render json: { error: "No pending tasks" }, status: :not_found
    else
      serialized_tasks = ActiveModelSerializers::SerializableResource.new(@tasks, each_serializer: TaskSerializer)
      render json: { tasks: serialized_tasks, meta: pagy_metadata(@pagy) }, status: :ok
    end
  end
  
  def by_priority
    @pagy, @tasks = pagy(current_user.tasks.by_priority.includes(:project))
    if @tasks.empty?
      render json: { error: "No tasks with valid priority" }, status: :not_found
    else
      serialized_tasks = ActiveModelSerializers::SerializableResource.new(@tasks, each_serializer: TaskSerializer)
      render json: { tasks: serialized_tasks, meta: pagy_metadata(@pagy) }, status: :ok
    end
  end
  private
  def task_params
    params.require(:task).permit(:title, :description, :status, :priority, :due_date,:completed_at,:project_id,:assignee_id)
  end
end
