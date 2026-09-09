class Api::V1::ProjectsController < ApiController
  include Pundit::Authorization
  def create
    @project = @current_user.projects.new(project_params)
    authorize [ :api, :v1, @project ]
    if @project.save
      render json: {
      message: "Project created successfully", project: ProjectSerializer.new(@project)
      }, status: :created
    else
      render json: { errors: project.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def index
    @pagy, @projects = pagy(current_user.projects.includes(:user))
    authorize [ :api, :v1, @projects ]
    serialized_projects = ActiveModelSerializers::SerializableResource.new(@projects, each_serializer: ProjectSerializer)
    render json: { projects: serialized_projects, meta: pagy_metadata(@pagy) }, status: :ok
  end

  def show
    @project = @current_user.projects.find(params[:id])
    authorize [ :api, :v1, @project ]
    render json: @project, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Project not found" }, status: :not_found
  end

  def update
    @project = @current_user.projects.find(params[:id])
    if @project==nil
      render json: { error: "Project not found" }, status: :not_found
    else
      authorize [ :api, :v1, @projects ]
      if @project.update(project_params)
        render json:
        { message: "Project updated successfully",
        project: ProjectSerializer.new(@project) }, status: :ok
      else
        render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
      end
    end
    rescue ActiveRecord::RecordNotFound
    render json: { error: "Project not found" }, status: :not_found
  end

  def destroy
    @project = @current_user.projects.find(params[:id])
    authorize [ :api, :v1, @projects ]
    if @project.destroy
      render json:
      { message: "Project deleted successfully",
      project: ProjectSerializer.new(@project) }, status: :ok
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Project not found" }, status: :not_found
  end

  private
  def project_params
    params.require(:project).permit(:name, :description, :status, :due_date)
  end
end
