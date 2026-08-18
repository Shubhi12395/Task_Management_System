class ApplicationController < ActionController::API
  before_action :authorize_request

  attr_reader :current_user

  private

  def authorize_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header 

    begin
      @decoded = JsonWebToken.decode(header)
      if @decoded
        @current_user = User.find(@decoded[:user_id])
      else
        render json: { errors: ['Unauthorized access'] }, status: :unauthorized
      end
    rescue ActiveRecord::RecordNotFound
      render json: { errors: ['User not found'] }, status: :unauthorized
    end
  end
  
end

