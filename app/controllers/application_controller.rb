class ApplicationController < ActionController::Base
    include Pundit::Authorization
rescue ActiveRecord::RecordNotFound
    render json: { error: " Not found" }, status: :not_found
end
