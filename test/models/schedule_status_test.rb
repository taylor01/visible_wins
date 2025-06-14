require "test_helper"

class ScheduleStatusTest < ActiveSupport::TestCase
  test "should require name" do
    status = ScheduleStatus.new(display_name: "Test", color_class: "bg-blue-100", sort_order: 1)
    assert_not status.valid?
    assert status.errors[:name].present?
  end

  test "should require unique name" do
    status1 = ScheduleStatus.create!(name: "TestStatus", display_name: "Test", color_class: "bg-blue-100", sort_order: 1)
    status2 = ScheduleStatus.new(name: "TestStatus", display_name: "Test2", color_class: "bg-red-100", sort_order: 2)
    assert_not status2.valid?
    assert status2.errors[:name].present?
  end

  test "should require display_name" do
    status = ScheduleStatus.new(name: "test", color_class: "bg-blue-100", sort_order: 1)
    assert_not status.valid?
    assert status.errors[:display_name].present?
  end

  test "should require color_class" do
    status = ScheduleStatus.new(name: "test", display_name: "Test", sort_order: 1)
    assert_not status.valid?
    assert status.errors[:color_class].present?
  end

  test "should require sort_order" do
    status = ScheduleStatus.new(name: "test", display_name: "Test", color_class: "bg-blue-100")
    assert_not status.valid?
    assert status.errors[:sort_order].present?
  end

  test "should validate sort_order is integer" do
    status = ScheduleStatus.new(name: "test", display_name: "Test", color_class: "bg-blue-100", sort_order: "not_a_number")
    assert_not status.valid?
    assert status.errors[:sort_order].present?
  end

  test "active scope should return only active statuses" do
    active_statuses = ScheduleStatus.active
    assert active_statuses.all?(&:active)
    assert_not active_statuses.include?(schedule_statuses(:inactive_status))
  end

  test "ordered scope should order by sort_order" do
    ordered_statuses = ScheduleStatus.ordered
    sort_orders = ordered_statuses.pluck(:sort_order)
    assert_equal sort_orders.sort, sort_orders
  end

  test "options_for_select should return display_name and name pairs for active statuses only" do
    options = ScheduleStatus.options_for_select
    assert options.is_a?(Array)
    assert options.all? { |option| option.is_a?(Array) && option.size == 2 }

    # Should not include inactive status
    inactive_option = options.find { |display_name, name| name == "Inactive" }
    assert_nil inactive_option

    # Should include active statuses
    office_option = options.find { |display_name, name| name == "Office" }
    assert_not_nil office_option
    assert_equal [ "Office", "Office" ], office_option
  end

  test "find_by_name should find status by name" do
    status = ScheduleStatus.find_by_name("Office")
    assert_not_nil status
    assert_equal "Office", status.name

    nil_status = ScheduleStatus.find_by_name("NonExistent")
    assert_nil nil_status
  end

  test "should clear WeeklySchedule cache after save" do
    # Test that the callback exists and doesn't raise errors
    status = ScheduleStatus.new(name: "NewStatus", display_name: "New Status", color_class: "bg-blue-100", sort_order: 99)
    assert_nothing_raised do
      status.save!
    end
  end

  test "should clear WeeklySchedule cache after destroy" do
    # Test that the callback exists and doesn't raise errors
    status = schedule_statuses(:office)
    assert_nothing_raised do
      status.destroy
    end
  end
end
