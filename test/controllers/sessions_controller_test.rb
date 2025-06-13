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

  test "should handle successful login via test helper" do
    sign_in_as(@user)
    get root_path
    assert_response :success
  end

  test "should require authentication for protected routes" do
    get root_path
    assert_redirected_to login_path
  end

  test "should handle authentication failure" do
    get login_path
    assert_response :success
    assert_select "h2", "Sign in to Visible Wins"
  end

  test "should logout user" do
    # Login user first
    sign_in_as(@user)
    
    # Then logout
    delete logout_path
    assert_redirected_to login_path
  end

  test "should redirect to login if accessing protected page" do
    get root_path
    assert_redirected_to login_path
  end

  test "should redirect logged in user away from login page" do
    # Login user first
    sign_in_as(@user)
    
    # Try to access login page again
    get login_path
    assert_redirected_to root_path
  end
end
