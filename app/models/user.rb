class User < ApplicationRecord
  belongs_to :team
  has_many :weekly_schedules, dependent: :destroy

  has_secure_password

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: %w[Executive Director Manager Staff] }

  scope :by_name, -> { order(:last_name, :first_name) }
  scope :admins, -> { where(admin: true) }

  def full_name
    "#{first_name} #{last_name}"
  end

  def display_name
    "#{last_name}, #{first_name}"
  end

  def current_week_schedule
    week_start = Date.current.beginning_of_week(:sunday)
    weekly_schedules.find_by(week_start_date: week_start)
  end

  def schedule_for_week(date)
    week_start = date.beginning_of_week(:sunday)
    weekly_schedules.find_by(week_start_date: week_start)
  end
end
