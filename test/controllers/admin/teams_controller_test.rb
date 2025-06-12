require "test_helper"

class Admin::TeamsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @team = teams(:development)
    @empty_team = teams(:empty_team)
    @admin = users(:admin)
  end

  test "should get index" do
    log_in_as(@admin)
    get admin_teams_path
    assert_response :success
  end

  test "should get show" do
    log_in_as(@admin)
    get admin_team_path(@team)
    assert_response :success
  end

  test "should get new" do
    log_in_as(@admin)
    get new_admin_team_path
    assert_response :success
  end

  test "should create team" do
    log_in_as(@admin)
    assert_difference('Team.count') do
      post admin_teams_path, params: { team: { name: Faker::Company.name } }
    end
    assert_redirected_to admin_teams_path
  end

  test "should get edit" do
    log_in_as(@admin)
    get edit_admin_team_path(@team)
    assert_response :success
  end

  test "should update team" do
    log_in_as(@admin)
    patch admin_team_path(@team), params: { team: { name: Faker::Company.name } }
    assert_redirected_to admin_teams_path
  end

  test "should destroy team" do
    log_in_as(@admin)
    assert_difference('Team.count', -1) do
      delete admin_team_path(@empty_team)
    end
    assert_redirected_to admin_teams_path
  end

  private

  def log_in_as(user)
    post login_path, params: { 
      email: user.email, 
      password: "password" 
    }
  end
end
