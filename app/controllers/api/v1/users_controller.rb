class Api::V1::UsersController < ApiController
  
  skip_before_action   :authorize_request, only: [:create, :login,]
  
  def create
    @user = User.new(user_params)
    if @user.save
      token = JsonWebToken.encode(user_id: @user.id)
      UserMailer.with(user: @user).welcome_email.deliver_later
      render json: { 
      message: 'User created and mail sent successfully', 
      token: token,
      user: { id: @user.id, name: @user.name, email: @user.email, } 
      }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def login
    user = User.find_by(email: params[:email])
    if user == nil
      render json: {
      message: "Invalid email"
      } ,status: :unprocessable_entity
    else
      if user.failed_attempts<5
        if user&.authenticate(params[:password])
          token=JsonWebToken.encode(user_id: user.id)
          # byebug
          user.update!(failed_attempts: 0) 
          render json: {
          message: "login successfully",
          token: token
          }, status: :ok
        else 
          user.increment!(:failed_attempts)  
          render json: {
          error: "please enter correct password", attempts: user.failed_attempts
          } ,status: :unauthorized
        end
        
      else
        render json: { message: "account locked due to maximum attempts failed"}, status: :too_many_requests
      end
    end
  end
  
  def logout
    render json: { 
    message: 'User logout successfully' 
    }, status: :ok
    
  end
  
  private
  
  def user_params
    params.require(:user).permit(:name, :email, :password,)
  end
end
