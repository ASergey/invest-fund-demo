class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_current_user

  def admin_access_denied(exception)
    redirect_to root_path, alert: exception.message
  end

  rescue_from CanCan::AccessDenied do |exception|
    authenticate_user!
    redirect_to new_user_session_path, alert: exception.message
  end

  protected

  def ajax_error(errors)
    render json: (errors.is_a?(String) ? {common: errors} : errors), status: :unprocessable_entity
  end

  def ajax_ok(data = {})
    render json: data
  end

  def set_current_user
    User.current_user = current_user
  end
end
