class Api::V1::UsersController < ApiController
  skip_before_action :authorize_request, only: [ :create, :login ]
  before_action :otp_verify, only: [ :forgot_pwd_reset ]
  def create
    @user = User.new(user_params)
    if @user.save
      token = JsonWebToken.encode(user_id: @user.id)
      UserMailer.with(user: @user).welcome_email.deliver_later
      render json: {
      message: "User created and mail sent successfully",
      token: token,
      user: { id: @user.id, name: @user.name, email: @user.email }
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
      }, status: :unprocessable_entity
    else
      if user.failed_attempts<5
        if user&.authenticate(params[:password])
          token = JsonWebToken.encode(user_id: user.id)
          user.update!(failed_attempts: 0, refresh_token: token)
          render json: {
          message: "login successfully", token: token
          }, status: :ok
        else
          user.increment!(:failed_attempts)
          render json: {
          error: "please enter correct password", attempts: user.failed_attempts
          }, status: :unauthorized
        end

      else
        render json: { message: "account locked due to maximum attempts failed" }, status: :too_many_requests
      end
    end
  end

  def logout
    current_user.refresh_token= nil
    current_user.save
    render json: {
    message: "User logout successfully"
    }, status: :ok
  end
  def password_reset
    @user = User.find_by(email: params[:user][:email])
    if @user== nil
      render json: { error: "Invalid Email" }, status: :not_found
    else
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
  end

  def forgot_password
    @user=User.find_by(email: params[:user][:email])
    if @user==nil
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
        current_user.password=params[:user][:new_password]
        current_user.otp_code=nil
        current_user.otp_expires_at=nil
        current_user.save
        render json: {
          message: "password update successfully" }, status: :ok
    end

    private

    def user_params
      params.require(:user).permit(:name, :email, :password,)
    end
    def otp_verify
      if current_user.otp_expires_at.nil? || current_user.otp_expires_at < Time.current
        return render json: { error: "Your OTP has expired. Please request a new one." }, status: :gone
        current_user.update(otp_expires_at: nil)
      end
      if current_user.otp_code.nil? || current_user.otp_code != params[:otp]
      render json: { error: "Invalid OTP. Please try again." }, status: :unauthorized
      end
    end
end
