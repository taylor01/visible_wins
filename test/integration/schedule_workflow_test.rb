require "test_helper"

class ScheduleWorkflowTest < ActionDispatch::IntegrationTest
  setup do
    @team = teams(:development)
    @user = users(:alice)
    @admin_user = users(:admin)
  end

  test "complete schedule management workflow" do
    # User logs in
    post login_path, params: {
      email: @user.email,
      password: "password"
    }
    assert_redirected_to root_path
    follow_redirect!

    # User views schedule page
    assert_response :success
    assert_select "h1", "Team Schedule"
    assert_select "table"

    # User clicks to edit their schedule
    get edit_schedule_path(@user)
    assert_response :success
    assert_select "h1", "Update My Schedule"

    # User updates their schedule
    patch schedule_path(@user), params: {
      weekly_schedule: {
        sunday: "OOO",
        monday: "Office",
        tuesday: "WFH",
        wednesday: "Office",
        thursday: "WFH",
        friday: "Office",
        saturday: "OOO"
      }
    }
    assert_redirected_to root_path
    follow_redirect!

    # Verify schedule was updated
    assert_match "Schedule updated successfully!", flash[:notice]
    
    # User navigates to next week
    next_week = Date.current.beginning_of_week(:sunday) + 1.week
    get root_path(week_start_date: next_week)
    assert_response :success
    
    # User filters by team
    get root_path(team_id: @team.id)
    assert_response :success
    assert_select "option[selected]", text: @team.name

    # User logs out
    delete logout_path
    assert_redirected_to login_path
  end

  test "admin user management workflow" do
    # Admin logs in
    post login_path, params: {
      email: @admin_user.email,
      password: "password"
    }
    assert_redirected_to root_path
    follow_redirect!

    # Admin accesses admin panel
    get admin_users_path
    assert_response :success
    assert_select "h1", "Users"

    # Admin views teams
    get admin_teams_path
    assert_response :success
    assert_select "h1"
  end

  test "unauthorized access protection" do
    # Try to access admin areas without login
    get admin_users_path
    assert_redirected_to login_path

    get admin_teams_path
    assert_redirected_to login_path

    # Try to access schedule edit without login
    get edit_schedule_path(@user)
    assert_redirected_to login_path

    # Login as regular user
    post login_path, params: {
      email: @user.email,
      password: "password"
    }

    # Try to access admin areas as regular user
    get admin_users_path
    assert_response :redirect # Should be redirected away

    get admin_teams_path
    assert_response :redirect # Should be redirected away
  end

  test "week navigation preserves filters" do
    # Login
    post login_path, params: {
      email: @user.email,
      password: "password"
    }

    # Navigate to filtered view
    get root_path(team_id: @team.id)
    assert_response :success

    # Check that week navigation links preserve team filter
    assert_select "a[href*='team_id=#{@team.id}']"
  end

  test "schedule validation and error handling" do
    # Login
    post login_path, params: {
      email: @user.email,
      password: "password"
    }

    # Try to update with invalid data
    patch schedule_path(@user), params: {
      weekly_schedule: {
        sunday: "invalid_status"
      }
    }
    assert_response :unprocessable_entity
    assert_select "form" # Should show form again with errors
  end
end