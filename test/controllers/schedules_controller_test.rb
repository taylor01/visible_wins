require "test_helper"

class SchedulesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @team = teams(:development)
    @user = users(:alice)
    @week_start = Date.current.beginning_of_week(:sunday)
    @schedule = weekly_schedules(:alice_current_week)
  end

  test "should get index without authentication" do
    get root_path
    assert_response :redirect
    assert_redirected_to login_path
  end

  test "should get index when logged in" do
    log_in_as(@user)
    get root_path
    assert_response :success
    assert_select "h1", "Team Schedule"
    assert_select "table"
  end

  test "should show current week by default" do
    log_in_as(@user)
    get root_path
    assert_response :success
    current_week = Date.current.beginning_of_week(:sunday)
    expected_date_range = "#{current_week.strftime('%B %d')} - #{(current_week + 6.days).strftime('%B %d, %Y')}"
    assert_select "p", text: expected_date_range
  end

  test "should filter by team" do
    log_in_as(@user)
    get root_path(team_id: @team.id)
    assert_response :success
    assert_select "option[selected]", text: @team.name
  end

  test "should navigate to different week" do
    log_in_as(@user)
    next_week = @week_start + 1.week
    get root_path(week_start_date: next_week)
    assert_response :success
    expected_date_range = "#{next_week.strftime('%B %d')} - #{(next_week + 6.days).strftime('%B %d, %Y')}"
    assert_select "p", text: expected_date_range
  end

  test "should get edit for current user" do
    log_in_as(@user)
    get edit_schedule_path(@user)
    assert_response :success
    assert_select "h1", "Update My Schedule"
  end

  test "should not allow editing other user's schedule" do
    other_user = users(:bob)
    log_in_as(@user)
    get edit_schedule_path(other_user)
    assert_response :redirect
  end

  test "should update schedule" do
    log_in_as(@user)
    patch schedule_path(@user), params: {
      weekly_schedule: {
        sunday: "Office",
        monday: "WFH",
        tuesday: "Office",
        wednesday: "WFH",
        thursday: "Office",
        friday: "WFH",
        saturday: "OOO"
      }
    }
    assert_redirected_to root_path
    assert_match "Schedule updated successfully!", flash[:notice]
  end

  test "should handle invalid schedule update" do
    log_in_as(@user)
    patch schedule_path(@user), params: {
      weekly_schedule: {
        sunday: "invalid_status"
      }
    }
    assert_response :unprocessable_entity
  end

  test "should preserve team filter in week navigation links" do
    log_in_as(@user)
    get root_path(team_id: @team.id)
    assert_response :success
    assert_select "a[href*='team_id=#{@team.id}']"
  end

  private

  def log_in_as(user)
    post login_path, params: { 
      email: user.email, 
      password: "password" 
    }
  end
end
