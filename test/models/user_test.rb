require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @team = Team.create!(name: "Engineering")
  end

  test "should create user with valid attributes" do
    user = User.new(
      first_name: "John",
      last_name: "Doe",
      email: "john@example.com",
      okta_sub: "test_sub_123",
      role: "Staff",
      team: @team,
      active: true
    )
    assert user.valid?
    assert user.save
  end

  test "should require first_name" do
    user = User.new(
      last_name: "Doe",
      email: "john@example.com",
      okta_sub: "test_sub_123",
      role: "Staff",
      team: @team,
      active: true
    )
    assert_not user.valid?
    assert user.errors[:first_name].present?
  end

  test "should require last_name" do
    user = User.new(
      first_name: "John",
      email: "john@example.com",
      okta_sub: "test_sub_123",
      role: "Staff",
      team: @team,
      active: true
    )
    assert_not user.valid?
    assert user.errors[:last_name].present?
  end

  test "should require email" do
    user = User.new(
      first_name: "John",
      last_name: "Doe",
      okta_sub: "test_sub_123",
      role: "Staff",
      team: @team,
      active: true
    )
    assert_not user.valid?
    assert user.errors[:email].present?
  end

  test "should require unique email" do
    User.create!(
      first_name: "John",
      last_name: "Doe",
      email: "john@example.com",
      okta_sub: "test_sub_123",
      role: "Staff",
      team: @team,
      active: true,
      profile_completed_at: 1.week.ago
    )

    duplicate_user = User.new(
      first_name: "Jane",
      last_name: "Smith",
      email: "john@example.com",
      okta_sub: "test_sub_456",
      role: "Manager",
      team: @team,
      active: true
    )
    assert_not duplicate_user.valid?
    assert duplicate_user.errors[:email].present?
  end

  test "should validate email format" do
    user = User.new(
      first_name: "John",
      last_name: "Doe",
      email: "invalid-email",
      okta_sub: "test_sub_123",
      role: "Staff",
      team: @team,
      active: true
    )
    assert_not user.valid?
    assert user.errors[:email].present?
  end

  test "should require role" do
    user = User.new(
      first_name: "John",
      last_name: "Doe",
      email: "john@example.com",
      okta_sub: "test_sub_123",
      team: @team,
      active: true
    )
    assert_not user.valid?
    assert user.errors[:role].present?
  end

  test "should validate role inclusion" do
    user = User.new(
      first_name: "John",
      last_name: "Doe",
      email: "john@example.com",
      okta_sub: "test_sub_123",
      role: "InvalidRole",
      team: @team,
      active: true
    )
    assert_not user.valid?
    assert user.errors[:role].present?
  end

  test "should accept valid roles" do
    %w[Executive Director Manager Staff].each do |role|
      user = User.new(
        first_name: "John",
        last_name: "Doe",
        email: "john-#{role.downcase}@example.com",
        okta_sub: "test_sub_#{role.downcase}",
        role: role,
        team: @team,
        active: true
      )
      assert user.valid?, "#{role} should be a valid role"
    end
  end

  test "should require team" do
    user = User.new(
      first_name: "John",
      last_name: "Doe",
      email: "john@example.com",
      okta_sub: "test_sub_123",
      role: "Staff",
      active: true
    )
    assert_not user.valid?
    assert user.errors[:team].present?
  end

  test "should require okta_sub for OIDC authentication" do
    user = User.new(
      first_name: "John",
      last_name: "Doe",
      email: "john@example.com",
      role: "Staff",
      team: @team,
      active: true
    )
    assert_not user.valid?
    assert user.errors[:okta_sub].present?
  end

  test "full_name should combine first and last name" do
    user = User.new(first_name: "John", last_name: "Doe")
    assert_equal "John Doe", user.full_name
  end

  test "display_name should show last name first" do
    user = User.new(first_name: "John", last_name: "Doe")
    assert_equal "Doe, John", user.display_name
  end

  test "by_name scope should order by last name then first name" do
    User.create!(
      first_name: "Zoe", last_name: "Zebra",
      email: Faker::Internet.unique.email, okta_sub: "test_zebra", role: "Staff", team: @team, active: true,
      profile_completed_at: 1.week.ago
    )
    User.create!(
      first_name: "Charlie", last_name: "Apple",
      email: Faker::Internet.unique.email, okta_sub: "test_apple", role: "Staff", team: @team, active: true,
      profile_completed_at: 1.week.ago
    )
    User.create!(
      first_name: "Bob", last_name: "Apple",
      email: Faker::Internet.unique.email, okta_sub: "test_bob_apple", role: "Staff", team: @team, active: true,
      profile_completed_at: 1.week.ago
    )

    ordered_users = User.by_name
    # Filter to just the test users we created
    test_users = ordered_users.where(okta_sub: [ "test_zebra", "test_apple", "test_bob_apple" ])

    # Should order by last name first, then first name
    assert_equal 3, test_users.count
    assert_equal "Apple", test_users.first.last_name
    assert_equal "Bob", test_users.first.first_name  # Bob comes before Charlie alphabetically
    assert_equal "Apple", test_users.second.last_name
    assert_equal "Charlie", test_users.second.first_name
    assert_equal "Zebra", test_users.third.last_name
    assert_equal "Zoe", test_users.third.first_name
  end

  test "admins scope should return only admin users" do
    admin = User.create!(
      first_name: Faker::Name.first_name, last_name: Faker::Name.last_name,
      email: Faker::Internet.unique.email, okta_sub: "test_admin", role: "Executive", team: @team,
      active: true, admin: true, profile_completed_at: 1.week.ago
    )
    User.create!(
      first_name: Faker::Name.first_name, last_name: Faker::Name.last_name,
      email: Faker::Internet.unique.email, okta_sub: "test_staff", role: "Staff", team: @team,
      active: true, admin: false, profile_completed_at: 1.week.ago
    )

    admins = User.admins
    assert_includes admins, admin
    assert admins.count >= 1  # Account for fixture admin user
  end

  test "current_week_schedule should return schedule for current week" do
    user = User.create!(
      first_name: "John", last_name: "Doe",
      email: "john@example.com", okta_sub: "test_john", role: "Staff", team: @team, active: true,
      profile_completed_at: 1.week.ago
    )

    current_week_start = Date.current.beginning_of_week(:sunday)
    schedule = WeeklySchedule.create!(
      user: user,
      week_start_date: current_week_start,
      monday: "Office"
    )

    assert_equal schedule, user.current_week_schedule
  end

  test "schedule_for_week should return schedule for specific week" do
    user = User.create!(
      first_name: "John", last_name: "Doe",
      email: "john@example.com", okta_sub: "test_john", role: "Staff", team: @team, active: true,
      profile_completed_at: 1.week.ago
    )

    specific_date = Date.parse("2024-01-15") # A Monday
    week_start = specific_date.beginning_of_week(:sunday)
    schedule = WeeklySchedule.create!(
      user: user,
      week_start_date: week_start,
      monday: "WFH"
    )

    assert_equal schedule, user.schedule_for_week(specific_date)
  end
end
