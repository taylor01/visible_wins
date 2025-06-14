class WeeklySchedule < ApplicationRecord
  belongs_to :user

  # Keep the constant for backward compatibility during transition
  SCHEDULE_OPTIONS = %w[Office WFH Vacation OOO TBD Travel].freeze

  validates :week_start_date, presence: true, uniqueness: { scope: :user_id }
  validates :sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday,
            inclusion: { in: ->(_) { valid_schedule_options } }, allow_blank: true

  validate :week_start_date_is_sunday

  scope :for_week, ->(date) { where(week_start_date: date.beginning_of_week(:sunday)) }
  scope :current_week, -> { for_week(Date.current) }
  scope :ordered, -> { order(:week_start_date) }

  def days
    %w[sunday monday tuesday wednesday thursday friday saturday]
  end

  def status_for_day(day)
    send(day.downcase)
  end

  def set_status_for_day(day, status)
    send("#{day.downcase}=", status)
  end

  def week_display
    week_start_date.strftime("%B %d, %Y")
  end

  # Class method to get valid schedule options from database
  def self.valid_schedule_options
    @valid_schedule_options ||= ScheduleStatus.active.pluck(:name) + [ nil, "" ]
  end

  # Method to get schedule options for forms
  def self.schedule_options_for_select
    ScheduleStatus.options_for_select
  end

  # Clear the cache when schedule statuses change
  def self.clear_schedule_options_cache
    @valid_schedule_options = nil
  end

  private

  def valid_schedule_options
    self.class.valid_schedule_options
  end

  def week_start_date_is_sunday
    return unless week_start_date.present?

    errors.add(:week_start_date, "must be a Sunday") unless week_start_date.sunday?
  end
end
