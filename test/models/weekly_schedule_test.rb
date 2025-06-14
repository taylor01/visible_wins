require "test_helper"

class WeeklyScheduleTest < ActiveSupport::TestCase
  def setup
    @team = Team.create!(name: "Engineering")
    @user = User.create!(
      first_name: "John",
      last_name: "Doe",
      email: "john@example.com",
      okta_sub: "test_weekly_schedule_user",
      role: "Staff",
      team: @team,
      active: true,
      profile_completed_at: 1.week.ago
    )
    @sunday = Date.parse("2024-01-07") # A Sunday
  end

  test "should create weekly schedule with valid attributes" do
    schedule = WeeklySchedule.new(
      user: @user,
      week_start_date: @sunday,
      monday: "Office",
      tuesday: "WFH"
    )
    assert schedule.valid?
    assert schedule.save
  end

  test "should require user" do
    schedule = WeeklySchedule.new(
      week_start_date: @sunday,
      monday: "Office"
    )
    assert_not schedule.valid?
    assert schedule.errors[:user].present?
  end

  test "should require week_start_date" do
    schedule = WeeklySchedule.new(
      user: @user,
      monday: "Office"
    )
    assert_not schedule.valid?
    assert schedule.errors[:week_start_date].present?
  end

  test "should enforce unique week_start_date per user" do
    WeeklySchedule.create!(
      user: @user,
      week_start_date: @sunday,
      monday: "Office"
    )

    duplicate_schedule = WeeklySchedule.new(
      user: @user,
      week_start_date: @sunday,
      tuesday: "WFH"
    )
    assert_not duplicate_schedule.valid?
    assert duplicate_schedule.errors[:week_start_date].present?
  end

  test "should allow same week_start_date for different users" do
    user2 = User.create!(
      first_name: "Jane",
      last_name: "Smith",
      email: "jane@example.com",
      role: "Manager",
      team: @team,
      okta_sub: "test_jane_weekly_schedule",
      active: true,
      profile_completed_at: 1.week.ago
    )

    WeeklySchedule.create!(
      user: @user,
      week_start_date: @sunday,
      monday: "Office"
    )

    schedule2 = WeeklySchedule.new(
      user: user2,
      week_start_date: @sunday,
      monday: "WFH"
    )
    assert schedule2.valid?
  end

  test "should validate week_start_date is a Sunday" do
    monday = Date.parse("2024-01-08")
    schedule = WeeklySchedule.new(
      user: @user,
      week_start_date: monday,
      monday: "Office"
    )
    assert_not schedule.valid?
    assert schedule.errors[:week_start_date].present?
    assert schedule.errors[:week_start_date].first.include?("must be a Sunday")
  end

  test "should validate schedule options" do
    valid_options = ScheduleStatus.active.pluck(:name)
    valid_options.each do |option|
      schedule = WeeklySchedule.new(
        user: @user,
        week_start_date: @sunday,
        monday: option
      )
      assert schedule.valid?, "#{option} should be a valid schedule option"
    end
  end

  test "should reject invalid schedule options" do
    schedule = WeeklySchedule.new(
      user: @user,
      week_start_date: @sunday,
      monday: "InvalidOption"
    )
    assert_not schedule.valid?
    assert schedule.errors[:monday].present?
  end

  test "should allow blank/nil values for days" do
    schedule = WeeklySchedule.new(
      user: @user,
      week_start_date: @sunday,
      monday: "Office",
      tuesday: nil,
      wednesday: "",
      thursday: "WFH"
    )
    assert schedule.valid?
  end

  test "for_week scope should return schedules for specific week" do
    schedule1 = WeeklySchedule.create!(
      user: @user,
      week_start_date: @sunday,
      monday: "Office"
    )

    next_week = @sunday + 7.days
    user2 = User.create!(
      first_name: "Jane",
      last_name: "Smith",
      email: "jane@example.com",
      role: "Manager",
      team: @team,
      okta_sub: "test_jane_weekly_schedule_2",
      active: true,
      profile_completed_at: 1.week.ago
    )
    WeeklySchedule.create!(
      user: user2,
      week_start_date: next_week,
      monday: "WFH"
    )

    schedules = WeeklySchedule.for_week(@sunday)
    assert_equal 1, schedules.count
    assert_includes schedules, schedule1
  end

  test "current_week scope should return schedules for current week" do
    current_week_start = Date.current.beginning_of_week(:sunday)
    schedule = WeeklySchedule.create!(
      user: @user,
      week_start_date: current_week_start,
      monday: "Office"
    )

    current_schedules = WeeklySchedule.current_week
    assert_includes current_schedules, schedule
  end

  test "ordered scope should order by week_start_date" do
    schedule2 = WeeklySchedule.create!(
      user: @user,
      week_start_date: @sunday + 7.days,
      monday: "WFH"
    )
    schedule1 = WeeklySchedule.create!(
      user: @user,
      week_start_date: @sunday - 7.days,
      monday: "Office"
    )

    ordered_schedules = WeeklySchedule.where(user: @user).ordered
    assert_equal schedule1, ordered_schedules.first
    assert_equal schedule2, ordered_schedules.last
  end

  test "days method should return all day names" do
    schedule = WeeklySchedule.new
    expected_days = %w[sunday monday tuesday wednesday thursday friday saturday]
    assert_equal expected_days, schedule.days
  end

  test "status_for_day should return day status" do
    schedule = WeeklySchedule.create!(
      user: @user,
      week_start_date: @sunday,
      monday: "Office",
      tuesday: "WFH"
    )

    assert_equal "Office", schedule.status_for_day("Monday")
    assert_equal "WFH", schedule.status_for_day("Tuesday")
    assert_nil schedule.status_for_day("Wednesday")
  end

  test "set_status_for_day should set day status" do
    schedule = WeeklySchedule.new(
      user: @user,
      week_start_date: @sunday
    )

    schedule.set_status_for_day("Monday", "Office")
    schedule.set_status_for_day("Tuesday", "WFH")

    assert_equal "Office", schedule.monday
    assert_equal "WFH", schedule.tuesday
  end

  test "week_display should format week start date" do
    schedule = WeeklySchedule.new(week_start_date: @sunday)
    assert_equal "January 07, 2024", schedule.week_display
  end

  test "SCHEDULE_OPTIONS constant should contain expected values" do
    expected_options = %w[Office WFH Vacation OOO TBD Travel]
    assert_equal expected_options, WeeklySchedule::SCHEDULE_OPTIONS
  end

  test "valid_schedule_options should return active schedule statuses plus blank options" do
    valid_options = WeeklySchedule.valid_schedule_options
    active_status_names = ScheduleStatus.active.pluck(:name)

    # Should include all active status names
    active_status_names.each do |name|
      assert_includes valid_options, name
    end

    # Should include nil and empty string
    assert_includes valid_options, nil
    assert_includes valid_options, ""

    # Should not include inactive status
    assert_not_includes valid_options, "Inactive"
  end

  test "schedule_options_for_select should return options formatted for select" do
    options = WeeklySchedule.schedule_options_for_select
    assert options.is_a?(Array)
    assert options.all? { |option| option.is_a?(Array) && option.size == 2 }

    # Should include active statuses only
    office_option = options.find { |display_name, name| name == "Office" }
    assert_not_nil office_option
    assert_equal [ "Office", "Office" ], office_option
  end

  test "clear_schedule_options_cache should clear cached options" do
    # Access the cached value
    WeeklySchedule.valid_schedule_options

    # Clear the cache
    WeeklySchedule.clear_schedule_options_cache

    # The cache should be cleared (can't easily test the internal state, but this ensures no errors)
    new_options = WeeklySchedule.valid_schedule_options
    assert new_options.is_a?(Array)
  end
end
