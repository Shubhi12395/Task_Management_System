class Api::V1::UsersController < ApiController
  skip_before_action :authorize_request, only: [ :new, :create, :forgot_pwd_reset, :forgot_password ]
  before_action :otp_verify, only: [ :forgot_pwd_reset ]
  include ActionController::Flash 
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      token = JsonWebToken.encode(user_id: @user.id)
      UserMailer.with(user: @user).welcome_email.deliver_later
      flash[:notice] = "signup successfully"
      redirect_to api_v1_auth_login_path
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def password_reset
    @user = current_user
    if @user&.authenticate(params[:user][:current_password])
      if @user.update(password: params[:user][:new_password])
        render json: {
        message: "password update successfully" }, status: :ok
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: "Incorrect current password" }, status: :unauthorized
    end
  end
  
  def forgot_password
    @user=User.find_by(email: params[:user][:email])
    if @user.nil?
      render json: { error: "Invalid email" }, status: :not_found
    else
      @user.otp_code=SecureRandom.random_number(1000..9999)
      @user.otp_expires_at = 10.minutes.from_now
      @user.save
      UserMailer.with(user: @user).otp_send.deliver_later
      render json: { message: "otp send to the email" }, status: :ok
    end
  end
  
  def forgot_pwd_reset
    if @user.update(password: params[:user][:password], otp_code: nil, otp_expires_at: nil)
      render json: {
      message: "password updated successfully" }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def otp_verify
    @user=User.find_by(email: params[:user][:email])
    if @user.nil?
      render json: { error: "Invalid Email" }, status: :not_found
    else
      if @user.otp_expires_at.nil? || @user.otp_expires_at < Time.current
        @user.update(otp_expires_at: nil)
        return render json: { error: "Your OTP has expired. Please request a new one." }, status: :gone
      end
      if @user.otp_code.nil? || @user.otp_code != params[:otp].to_i
        render json: { error: "Invalid OTP. Please try again." }, status: :unauthorized
      end
    end
  end
  private
  
  def user_params
    params.require(:user).permit(:name, :email, :password,)
  end
end
