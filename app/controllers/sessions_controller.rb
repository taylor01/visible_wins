class SessionsController < ApplicationController
  skip_before_action :require_login
  
  def new
    redirect_to root_path if logged_in?
  end

  # OIDC callback handler
  def omniauth_callback
    auth_data = request.env['omniauth.auth']
    
    # Find existing user by Okta sub or create new one
    user = User.find_by(okta_sub: auth_data.uid)
    
    if user
      # Update existing user with latest Okta data
      user = User.update_from_okta(user, auth_data)
    else
      # Create new user from Okta data
      user = User.create_from_okta(auth_data)
    end
    
    if user.active?
      session[:user_id] = user.id
      redirect_to root_path, notice: "Welcome, #{user.first_name}!"
    else
      redirect_to login_path, alert: "Your account has been deactivated. Please contact IT support."
    end
  rescue => e
    Rails.logger.error "OIDC authentication failed: #{e.message}"
    redirect_to login_path, alert: "Authentication failed. Please try again or contact IT support."
  end

  # Handle OIDC authentication failures
  def omniauth_failure
    Rails.logger.error "OIDC failure: #{params[:message]}"
    redirect_to login_path, alert: "Authentication failed: #{params[:message]}"
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: "You have been logged out"
  end

  # Test-only method for simulating login
  def test_login
    return head :not_found unless Rails.env.test?
    
    user_id = params[:user_id]
    if user_id && User.exists?(user_id)
      session[:user_id] = user_id.to_i
      head :ok
    else
      head :unprocessable_entity
    end
  end
end
