class ApplicationController < ActionController::Base
  include Pundit::Authorization
  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: " Not found" }, status: :not_found
  end
end
