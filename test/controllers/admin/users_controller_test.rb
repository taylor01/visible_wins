require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:alice)
    @admin = users(:admin)
    @team = teams(:development)
  end

  test "should get index" do
    log_in_as(@admin)
    get admin_users_path
    assert_response :success
  end

  test "should get show" do
    log_in_as(@admin)
    get admin_user_path(@user)
    assert_response :success
  end

  test "should get new" do
    log_in_as(@admin)
    get new_admin_user_path
    assert_response :success
  end

  test "should create user" do
    log_in_as(@admin)
    assert_difference('User.count') do
      post admin_users_path, params: { 
        user: { 
          first_name: Faker::Name.first_name, 
          last_name: Faker::Name.last_name, 
          email: Faker::Internet.unique.email, 
          password: "password", 
          role: "Staff",
          team_id: @team.id 
        } 
      }
    end
    assert_redirected_to admin_users_path
  end

  test "should get edit" do
    log_in_as(@admin)
    get edit_admin_user_path(@user)
    assert_response :success
  end

  test "should update user" do
    log_in_as(@admin)
    patch admin_user_path(@user), params: { 
      user: { 
        first_name: Faker::Name.first_name,
        role: "Manager"
      } 
    }
    assert_redirected_to admin_users_path
  end

  test "should destroy user" do
    log_in_as(@admin)
    assert_difference('User.count', -1) do
      delete admin_user_path(@user)
    end
    assert_redirected_to admin_users_path
  end

  private

  def log_in_as(user)
    post login_path, params: { 
      email: user.email, 
      password: "password" 
    }
  end
end
