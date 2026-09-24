class ApiController < ActionController::Base
  layout "application"
  include Pagy::Backend
  include Pundit::Authorization
  before_action :authorize_request
  attr_reader :current_user
  
  private
  
  def authorize_request
    header = request.headers["Authorization"]
    token = header.split(" ").last if header
    token ||= cookies.signed[:refresh_token]

    if token.blank?
      return render json: { errors: [ "Unauthorized Access - Missing Token" ] }, status: :unauthorized
    end
    
    begin
      @decoded = JsonWebToken.decode(token)
      return render json: { errors: [ "Unauthorized access - Token has expired" ] }, status: :unauthorized if @decoded.nil?
      
      user_id = @decoded[:user_id] || @decoded["user_id"]
      user = User.find(user_id)
      
      @current_user = user
    rescue ActiveRecord::RecordNotFound
      render json: { errors: [ "User record not found" ] }, status: :unauthorized
    rescue JWT::DecodeError,JWT::ExpiredSignature
      render json: { errors: [ "Invalid token signature" ] }, status: :unauthorized
    end
  end
end
