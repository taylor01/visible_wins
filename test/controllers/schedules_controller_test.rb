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
    sign_in_as(@user)
    get root_path
    assert_response :success
    assert_select "h1", "Team Schedule"
    assert_select "table"
  end

  test "should show current week by default" do
    sign_in_as(@user)
    get root_path
    assert_response :success
    current_week = Date.current.beginning_of_week(:sunday)
    expected_date_range = "#{current_week.strftime('%B %d')} - #{(current_week + 6.days).strftime('%B %d, %Y')}"
    assert_select "p", text: expected_date_range
  end

  test "should filter by team" do
    sign_in_as(@user)
    get root_path(team_id: @team.id)
    assert_response :success
    assert_select "option[selected]", text: @team.name
  end

  test "should navigate to different week" do
    sign_in_as(@user)
    next_week = @week_start + 1.week
    get root_path(week_start_date: next_week)
    assert_response :success
    expected_date_range = "#{next_week.strftime('%B %d')} - #{(next_week + 6.days).strftime('%B %d, %Y')}"
    assert_select "p", text: expected_date_range
  end

  test "should get edit for current user" do
    sign_in_as(@user)
    get edit_schedule_path(@user)
    assert_response :success
    assert_select "h1", "Update My Schedule"
  end

  test "should not allow editing other user's schedule" do
    other_user = users(:bob)
    sign_in_as(@user)
    get edit_schedule_path(other_user)
    assert_response :redirect
  end

  test "should update schedule" do
    sign_in_as(@user)
    patch schedule_path(@user), params: {
      weekly_schedule: {
        week_start_date: @week_start,
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
    sign_in_as(@user)
    patch schedule_path(@user), params: {
      weekly_schedule: {
        week_start_date: @week_start,
        sunday: "invalid_status"
      }
    }
    assert_response :unprocessable_entity
  end

  test "should preserve team filter in week navigation links" do
    sign_in_as(@user)
    get root_path(team_id: @team.id)
    assert_response :success
    assert_select "a[href*='team_id=#{@team.id}']"
  end

  test "should default to current week before Thursday" do
    sign_in_as(@user)
    # Mock Date.current to be a Wednesday
    travel_to Date.new(2025, 1, 15) do # Wednesday
      get edit_schedule_path(@user)
      assert_response :success
      # Should show current week (January 12 - January 18, 2025)
      assert_select "p", text: "January 12 - January 18, 2025"
    end
  end

  test "should default to next week on Thursday or later" do
    sign_in_as(@user)
    # Mock Date.current to be a Thursday
    travel_to Date.new(2025, 1, 16) do # Thursday
      get edit_schedule_path(@user)
      assert_response :success
      # Should show next week (January 19 - January 25, 2025)
      assert_select "p", text: "January 19 - January 25, 2025"
    end
  end

  test "should allow explicit week selection regardless of day" do
    sign_in_as(@user)
    specific_week = Date.new(2025, 2, 2) # Future Sunday
    travel_to Date.new(2025, 1, 16) do # Thursday
      get edit_schedule_path(@user, week_start_date: specific_week)
      assert_response :success
      # Should show specified week (February 02 - February 08, 2025)
      assert_select "p", text: "February 02 - February 08, 2025"
    end
  end

  test "should update schedule for specified week" do
    sign_in_as(@user)
    next_week = @week_start + 1.week
    
    patch schedule_path(@user), params: {
      weekly_schedule: {
        week_start_date: next_week,
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
    
    # Verify the schedule was created for the correct week
    schedule = @user.weekly_schedules.find_by(week_start_date: next_week)
    assert_not_nil schedule
    assert_equal "Office", schedule.sunday
    assert_equal "WFH", schedule.monday
  end
end
