class WeeklySchedule < ApplicationRecord
  belongs_to :user

  SCHEDULE_OPTIONS = %w[Office WFH Vacation OOO TBD Travel].freeze

  validates :week_start_date, presence: true, uniqueness: { scope: :user_id }
  validates :sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday,
            inclusion: { in: SCHEDULE_OPTIONS + [nil, ""] }, allow_blank: true

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

  private

  def week_start_date_is_sunday
    return unless week_start_date.present?
    
    errors.add(:week_start_date, "must be a Sunday") unless week_start_date.sunday?
  end
end
