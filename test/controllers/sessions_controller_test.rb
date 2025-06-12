require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:alice)
  end

  test "should get login page" do
    get login_path
    assert_response :success
    assert_select "h2", "Sign in to Visible Wins"
    assert_select "form"
  end

  test "should login with valid credentials" do
    post login_path, params: {
      email: @user.email,
      password: "password"
    }
    assert_redirected_to root_path
    assert_equal @user.id, session[:user_id]
  end

  test "should not login with invalid email" do
    post login_path, params: {
      email: "invalid@example.com",
      password: "password"
    }
    assert_response :unprocessable_entity
    assert_select "p", "Invalid email or password"
    assert_nil session[:user_id]
  end

  test "should not login with invalid password" do
    post login_path, params: {
      email: @user.email,
      password: "wrongpassword"
    }
    assert_response :unprocessable_entity
    assert_select "p", "Invalid email or password"
    assert_nil session[:user_id]
  end

  test "should logout user" do
    # First login
    post login_path, params: {
      email: @user.email,
      password: "password"
    }
    assert_equal @user.id, session[:user_id]

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
    # Login first
    post login_path, params: {
      email: @user.email,
      password: "password"
    }
    
    # Try to access login page again
    get login_path
    assert_redirected_to root_path
  end
end
