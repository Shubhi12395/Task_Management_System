class Api::V1::ProfileController < ApplicationController
  def show
    render json: { 
    id: @current_user.id,
    name: @current_user.name,
    email: @current_user.email 
    }, status: :ok
  end
  def update
    if @current_user.update(user_params)
      render json: { message: 'Profile updated successfully', user: @current_user }, status: :ok
    else
      render json: { errors: @current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  private
  
  def user_params
    params.require(:user).permit(:name, :email, :password,)
  end
end
