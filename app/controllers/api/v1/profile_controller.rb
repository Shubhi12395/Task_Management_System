class Api::V1::ProfileController < ApiController
  def show
    # render json: {
    # id: @current_user.id,
    # name: @current_user.name,
    # email: @current_user.email
    # }, status: :ok
  end
  def edit
    @current_user
  end
  
  def update
    if @current_user.update(user_params)
      # render json: { message: "Profile updated successfully", user: @current_user }, status: :ok
       redirect_to "/api/v1/users/me", notice: "Profile updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def avatar
    if params[:avatar].present? && @current_user.avatar.attach(params[:avatar])
      render json: {
      message: "Avatar uploaded successfully",
      avatar:  rails_blob_url(@current_user.avatar)
      }, status: :ok
    else
      render json: { errors: "Failed to save avatar attachment" }, status: :unprocessable_entity
    end
  end
  
  private
  def user_params
    params.require(:user).permit(:name, :email,)
  end
end
