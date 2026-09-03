class ApiController < ActionController::API
  include Pagy::Backend
  before_action :authorize_request
  attr_reader :current_user

  private

  def authorize_request
    header = request.headers["Authorization"]
    header = header.split(" ").last if header

    if header.blank?
      return render json: { errors: [ "Unauthorized Access" ] }, status: :unauthorized
    end

    begin
      @decoded = JsonWebToken.decode(header)
      return render json: { errors: [ "Unauthorized access - Invalid token payload" ] }, status: :unauthorized if @decoded.nil?

      user_id = @decoded[:user_id] || @decoded["user_id"]
      @current_user = User.find(user_id)
    rescue ActiveRecord::RecordNotFound
      render json: { errors: [ "User record not found" ] }, status: :unauthorized
    rescue JWT::DecodeError
      render json: { errors: [ "Invalid token signature" ] }, status: :unauthorized
    end
  end
end
