class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :require_login

  private

  def current_user
    return nil unless session[:user_id]

    @current_user ||= begin
      user = User.find_by(id: session[:user_id])
      # Clear stale session if user no longer exists
      session[:user_id] = nil unless user
      user
    end
  end
  helper_method :current_user

  def logged_in?
    !!current_user
  end
  helper_method :logged_in?

  def require_login
    redirect_to login_path unless logged_in?
  end

  def require_admin
    redirect_to root_path unless current_user&.admin?
  end
end
