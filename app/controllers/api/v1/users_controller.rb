class Api::V1::UsersController < ApplicationController
  
  skip_before_action   :authorize_request, only: [:create, :login,]
  
  def create
    user = User.new(user_params)
    if user.save
      token = JsonWebToken.encode(user_id: user.id)
      render json: { 
      message: 'User created successfully', 
      token: token,
      user: { id: user.id, name:user.name, email: user.email } 
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def login
    #  byebug
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      token=JsonWebToken.encode(user_id: user.id)
      render json: {
      message: "login successfully",
      token: token
      }, status: :ok
    else 
      render json: {
      error: "invalid email and password"
      }, status: :unauthorized
    end
  end
  def logout
    user = User.find_by(id: params[:id]) 
    user.authorize_request = nil
    user.save
    render json: { 
    message: 'User logout successfully', 
    }, status: :ok
  end
  private
  
  def user_params
    params.require(:user).permit(:name, :email, :password,)
  end
end
