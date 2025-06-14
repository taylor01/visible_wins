class ScheduleStatus < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :display_name, presence: true
  validates :color_class, presence: true
  validates :sort_order, presence: true, numericality: { only_integer: true }

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:sort_order) }

  # Clear WeeklySchedule cache when schedule statuses change
  after_save :clear_weekly_schedule_cache
  after_destroy :clear_weekly_schedule_cache

  def self.options_for_select
    active.ordered.pluck(:display_name, :name)
  end

  def self.find_by_name(name)
    find_by(name: name)
  end

  private

  def clear_weekly_schedule_cache
    WeeklySchedule.clear_schedule_options_cache
  end
end
