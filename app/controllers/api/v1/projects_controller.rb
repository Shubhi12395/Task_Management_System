class Api::V1::ProjectsController < ApiController
  include Pundit::Authorization
  
  def new
    @project= Project.new
  end
  
  def create
    @project = @current_user.projects.new(project_params)
    authorize [ :api, :v1, @project ]
    if @project.save
      redirect_to api_v1_projects_path, notice: "Project created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def index
    @pagy, @projects = pagy(current_user.projects&.includes(:user))
    authorize [ :api, :v1, @projects ]
    # serialized_projects = ActiveModelSerializers::SerializableResource.new(@projects, each_serializer: ProjectSerializer)
    # render json: { projects: serialized_projects, meta: pagy_metadata(@pagy) }, status: :ok
  end
  
  def show
    @project = @current_user.projects.find(params[:id])
    authorize [ :api, :v1, @project ]
    # render json: @project, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Project not found" }, status: :not_found
  end
  
  def edit
    @project = current_user.projects.find(params[:id])
    authorize [ :api, :v1, @project ]
  end
  
  def update
    @project = @current_user.projects.find(params[:id])
    if @project.empty?
      render json: { error: "Project not found" }, status: :not_found
    else
      authorize [ :api, :v1, @project ]
      if @project.update(project_params)
        
        redirect_to "/api/v1/projects/#{@project.id}", notice: "Project updated successfully!"
      else
        render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Project not found" }, status: :not_found
  end
  
  def destroy
    @project = @current_user.projects.find(params[:id])
    authorize [ :api, :v1, @project ]
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
    if params[:project].present?
      params.require(:project).permit(:name, :description, :status, :due_date)
    else
      params.permit(:name, :description, :status, :due_date)
    end
  end
end
