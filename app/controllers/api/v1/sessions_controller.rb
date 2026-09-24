class Api::V1::SessionsController < ApiController
  skip_before_action :authorize_request, only: [ :new, :login ]
  include ActionController::Cookies
  
  def new
    
  end
  
  def login
    @user = User.find_by(email: params[:email])
    if @user.nil?
      render json: {
      message: "Invalid email"
      }, status: :unprocessable_entity
    else
      if @user.time_stamp > Time.current
        return render json: { message: "try after sometime" }
      end
      if @user.failed_attempts < 5
        if @user&.authenticate(params[:password])
          token= JsonWebToken.encode(user_id: @user.id)
          @user.update!(failed_attempts: 0, refresh_token: token)
          cookies.signed[:refresh_token] = { value: token, httponly: true, expires: 24.hours.from_now}
          render json: {message: "login successfully", token: token}, status: :ok
        else
          @user.increment!(:failed_attempts)
          render json: {
          error: "please enter correct password", attempts: @user.failed_attempts
          }, status: :unauthorized
        end
        
      else
        @user.failed_attempts = 0
        @user.time_stamp=10.minutes.from_now
        @user.save!
        render json: { message: "account locked due to maximum attempts failed please try after sometime" }, status: :too_many_requests
      end
    end
  end
  
  def logout
    if @current_user
      @current_user.update!(refresh_token: nil)
    end
    cookies.delete(:jwt_token)
    @current_user = nil
    redirect_to "/api/v1/auth/login", status: :see_other
  end
  
  
  private
  
  def user_params
    params.require(:user).permit(:name, :email, :password,)
  end
end