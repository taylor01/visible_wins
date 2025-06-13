require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:alice)
  end

  test "should get login page" do
    get login_path
    assert_response :success
    assert_select "h2", "Sign in to Visible Wins"
    assert_select "a[href*='auth/okta']", "Sign in with Okta"
  end

  test "should handle OIDC callback with valid user" do
    # Simulate successful OIDC callback
    auth_data = {
      'uid' => @user.okta_sub,
      'info' => {
        'email' => @user.email,
        'given_name' => @user.first_name,
        'family_name' => @user.last_name
      }
    }
    
    request.env['omniauth.auth'] = OmniAuth::AuthHash.new(auth_data)
    get "/auth/okta/callback"
    
    assert_redirected_to root_path
    assert_equal @user.id, session[:user_id]
  end

  test "should handle OIDC callback with new user" do
    # Simulate OIDC callback for new user
    auth_data = {
      'uid' => 'new_user_sub_123',
      'info' => {
        'email' => 'newuser@example.com',
        'given_name' => 'New',
        'family_name' => 'User'
      }
    }
    
    request.env['omniauth.auth'] = OmniAuth::AuthHash.new(auth_data)
    
    assert_difference 'User.count', 1 do
      get "/auth/okta/callback"
    end
    
    new_user = User.find_by(okta_sub: 'new_user_sub_123')
    assert_not_nil new_user
    assert_equal 'newuser@example.com', new_user.email
  end

  test "should handle OIDC failure" do
    get "/auth/okta/failure", params: { message: "invalid_credentials" }
    assert_redirected_to login_path
    assert_nil session[:user_id]
  end

  test "should logout user" do
    # Simulate logged in user
    session[:user_id] = @user.id
    
    # Then logout
    delete logout_path
    assert_redirected_to login_path
    assert_nil session[:user_id]
  end

  test "should redirect to login if accessing protected page" do
    get root_path
    assert_redirected_to login_path
  end

  test "should redirect logged in user away from login page" do
    # Simulate logged in user
    session[:user_id] = @user.id
    
    # Try to access login page again
    get login_path
    assert_redirected_to root_path
  end
end
