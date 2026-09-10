class Api::V1::TasksController < ApiController
  include Pundit::Authorization
  def create
    project = current_user.projects.find(params[:task][:project_id])
    @task = project.tasks.new(task_params)
    authorize [ :api, :v1, @task ]
    @task.creator_id=current_user.id
    if @task.save
      render json: {
      message: "Task created successfully", task: TaskSerializer.new(@task)
      }, status: :created
    else
      render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Project not found" }, status: :not_found
  end

  def index
    @tasks=current_user.tasks.includes(:project)
    if @tasks==nil
      render json: { error: " task not assigned" }, status: :not_found
    else
      authorize [ :api, :v1, @tasks ]
      @pagy, @tasks = pagy(@tasks)
      serialized_tasks = ActiveModelSerializers::SerializableResource.new(@tasks, each_serializer: TaskSerializer)
      render json: { tasks: serialized_tasks, meta: pagy_metadata(@pagy) }, status: :ok
    end
  end

  def show
    @task=@current_user.tasks.find(params[:id])
    authorize [ :api, :v1, @task ]
    render json: @task, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Task not found" }, status: :not_found
  end

  def sort
    scope = current_user.tasks.includes(:project)
    authorize [ :api, :v1, scope ]
    scope = scope.by_priority if params[:sort] == "priority"
    scope = scope.order(due_date: :asc) if params[:sort] == "due_date"
    @pagy, @tasks = pagy(scope)
    serialized_tasks = ActiveModelSerializers::SerializableResource.new(@tasks, each_serializer: TaskSerializer)
    render json: { tasks: serialized_tasks, meta: pagy_metadata(@pagy) }, status: :ok
  end

  def search
    @task=@current_user.tasks
    authorize [ :api, :v1, @task ]
    term="%#{params[:search]}%"
    @task = @task.where("tasks.title ILIKE ? OR tasks.description ILIKE ?", term, term)
    if @task.empty?
      render json: { error: "Task not found" }, status: :not_found
    else
      render json: @task, status: :ok
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Task not found" }, status: :not_found
  end

  def update
    @task = @current_user.tasks
    authorize [ :api, :v1, @task ]
    @task = @task.find(params[:id])

    if @task.update(task_params)
      render json:{ message: "Task updated successfully",
      task: TaskSerializer.new(@task) }, status: :ok
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Task not found" }, status: :not_found
  end

  def update_all
    @tasks= @current_user.tasks
    authorize [ :api, :v1, @tasks ]
    @tasks= @tasks.where(id: params[:ids]).update(status: 2)
    serialized_tasks = ActiveModelSerializers::SerializableResource.new(@tasks, each_serializer: TaskSerializer)
    render json: { message: "Tasks updated successfully", tasks: serialized_tasks}, status: :ok
  end

  def destroy
    @task = @current_user.tasks
    authorize [ :api, :v1, @task ]
    @task = @task.find(params[:id])
    if @task.destroy
      render json:{ message: "Task deleted successfully",task: TaskSerializer.new(@task) }, status: :ok
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Task not found" }, status: :not_found
  end

  def destroy_all
    @tasks=@current_user.tasks
    authorize [ :api, :v1, @tasks ]
     @tasks.where(id: params[:ids]).destroy_all
    render json: { message: "Tasks deleted successfully" }, status: :ok

  rescue ActiveRecord::RecordNotFound
    render json: { error: "Task not found" }, status: :not_found
  end

  def duetoday
    @pagy, @tasks = pagy(current_user.tasks.duetoday.includes(:project))
    if @tasks.empty?
      render json: { error: "No tasks due today" }, status: :not_found
    else
      authorize [ :api, :v1, @tasks ]
      serialized_tasks = ActiveModelSerialicurrent_user.zers::SerializableResource.new(@tasks, each_serializer: TaskSerializer)
      render json: { tasks: serialized_tasks, meta: pagy_metadata(@pagy) }, status: :ok
    end
  end

  def overdue
    @pagy, @tasks = pagy(current_user.tasks.overdue.includes(:project))
    if @tasks.empty?
      render json: { error: "No overdue tasks" }, status: :not_found
    else
      authorize [ :api, :v1, @tasks ]
      serialized_tasks = ActiveModelSerializers::SerializableResource.new(@tasks, each_serializer: TaskSerializer)
      render json: { tasks: serialized_tasks, meta: pagy_metadata(@pagy) }, status: :ok
    end
  end

  def pending
    @pagy, @tasks = pagy(current_user.tasks.pending.includes(:project))
    if @tasks.empty?
      render json: { error: "No pending tasks" }, status: :not_found
    else
      authorize [ :api, :v1, @tasks ]
      serialized_tasks = ActiveModelSerializers::SerializableResource.new(@tasks, each_serializer: TaskSerializer)
      render json: { tasks: serialized_tasks, meta: pagy_metadata(@pagy) }, status: :ok
    end
  end

  def by_priority
    @pagy, @tasks = pagy(current_user.tasks.by_priority.includes(:project))
    if @tasks.empty?
      render json: { error: "No tasks with valid priority" }, status: :not_found
    else
      authorize [ :api, :v1, @tasks ]
      serialized_tasks = ActiveModelSerializers::SerializableResource.new(@tasks, each_serializer: TaskSerializer)
      render json: { tasks: serialized_tasks, meta: pagy_metadata(@pagy) }, status: :ok
    end
  end

  private
  def task_params
    params.require(:task).permit(:title, :description, :status, :priority, :due_date, :completed_at, :project_id, :assignee_id, :parent_id)
  end
end
