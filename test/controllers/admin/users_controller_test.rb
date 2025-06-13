require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:alice)
    @admin = users(:admin)
    @team = teams(:development)
  end

  test "should get index" do
    sign_in_as(@admin)
    get admin_users_path
    assert_response :success
  end

  test "should get show" do
    sign_in_as(@admin)
    get admin_user_path(@user)
    assert_response :success
  end

  test "should get new" do
    sign_in_as(@admin)
    get new_admin_user_path
    assert_response :success
  end

  test "should create user" do
    sign_in_as(@admin)
    assert_difference('User.count') do
      post admin_users_path, params: { 
        user: { 
          first_name: Faker::Name.first_name, 
          last_name: Faker::Name.last_name, 
          email: Faker::Internet.unique.email, 
          okta_sub: Faker::Alphanumeric.alpha(number: 20), 
          role: "Staff",
          team_id: @team.id,
          active: true
        } 
      }
    end
    assert_redirected_to admin_users_path
  end

  test "should get edit" do
    sign_in_as(@admin)
    get edit_admin_user_path(@user)
    assert_response :success
  end

  test "should update user" do
    sign_in_as(@admin)
    patch admin_user_path(@user), params: { 
      user: { 
        first_name: Faker::Name.first_name,
        role: "Manager"
      } 
    }
    assert_redirected_to admin_users_path
  end

  test "should destroy user" do
    sign_in_as(@admin)
    assert_difference('User.count', -1) do
      delete admin_user_path(@user)
    end
    assert_redirected_to admin_users_path
  end

end
