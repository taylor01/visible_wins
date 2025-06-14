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


  test "should get edit" do
    sign_in_as(@admin)
    get edit_admin_user_path(@user)
    assert_response :success
  end

  test "should update user" do
    sign_in_as(@admin)
    patch admin_user_path(@user), params: {
      user: {
        role: "Manager",
        team_id: @team.id,
        active: false
      }
    }
    assert_redirected_to admin_users_path
    @user.reload
    assert_equal "Manager", @user.role
    assert_equal @team.id, @user.team_id
    assert_equal false, @user.active
  end

  test "should destroy user" do
    sign_in_as(@admin)
    assert_difference("User.count", -1) do
      delete admin_user_path(@user)
    end
    assert_redirected_to admin_users_path
  end
end
