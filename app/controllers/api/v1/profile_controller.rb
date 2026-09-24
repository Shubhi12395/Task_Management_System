class Api::V1::ProfileController < ApiController
  def show
    render json: @current_user, status: :ok
  end

  def edit
    @current_user
  end
  
  def update
    if @current_user.update(user_params)
      render json: { message: "Profile updated successfully", user: @current_user }, status: :ok
    else
     render json: { error: @current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def avatar
    if params[:avatar].present? && @current_user.avatar.attach(params[:avatar])
       redirect_to "/api/v1/users/me", notice: "Profile updated successfully!"
      # render json: {
      # message: "Avatar uploaded successfully",
      # avatar:  rails_blob_url(@current_user.avatar)
      # }, status: :ok
    else
      render json: { errors: "Failed to save avatar attachment" }, status: :unprocessable_entity
    end
  end
  
  private
  def user_params
    params.require(:user).permit(:name, :email,)
  end
end
