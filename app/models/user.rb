class User < ApplicationRecord
  belongs_to :team
  has_many :weekly_schedules, dependent: :destroy

  # OIDC Authentication - no password needed
  validates :okta_sub, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: %w[Executive Director Manager Staff] }
  validates :active, inclusion: { in: [ true, false ] }

  scope :by_name, -> { order(:last_name, :first_name) }
  scope :admins, -> { where(admin: true) }
  scope :active, -> { where(active: true) }
  scope :by_department, ->(dept) { where(department: dept) if dept.present? }

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

  # Manager hierarchy methods
  def manager
    return nil if manager_email.blank?
    User.find_by(email: manager_email)
  end

  def direct_reports
    User.where(manager_email: email)
  end

  def has_direct_reports?
    direct_reports.any?
  end

  # OIDC user creation
  def self.create_from_okta(auth_data)
    user_info = auth_data.info
    extra_data = auth_data.extra

    create!(
      okta_sub: auth_data.uid,
      email: user_info.email,
      first_name: user_info.given_name || user_info.first_name,
      last_name: user_info.family_name || user_info.last_name,

      # Extended attributes from Okta
      employee_id: extra_data&.dig(:employee_number),
      phone_number: extra_data&.dig(:phone_number),
      title: extra_data&.dig(:title),
      department: extra_data&.dig(:department),
      office_location: extra_data&.dig(:office_location),
      manager_email: extra_data&.dig(:manager),
      hire_date: parse_hire_date(extra_data&.dig(:hire_date)),
      employee_type: extra_data&.dig(:employee_type),

      # Role and team assignment
      role: map_title_to_role(extra_data&.dig(:title)),
      admin: admin_from_groups(extra_data&.dig(:groups)),
      team: assign_team_from_attributes(extra_data),
      active: true
    )
  end

  def self.update_from_okta(user, auth_data)
    user_info = auth_data.info
    extra_data = auth_data.extra

    user.update!(
      email: user_info.email,
      first_name: user_info.given_name || user_info.first_name,
      last_name: user_info.family_name || user_info.last_name,

      # Update extended attributes
      employee_id: extra_data&.dig(:employee_number),
      phone_number: extra_data&.dig(:phone_number),
      title: extra_data&.dig(:title),
      department: extra_data&.dig(:department),
      office_location: extra_data&.dig(:office_location),
      manager_email: extra_data&.dig(:manager),
      hire_date: parse_hire_date(extra_data&.dig(:hire_date)),
      employee_type: extra_data&.dig(:employee_type),

      # Update role and admin status
      role: map_title_to_role(extra_data&.dig(:title)),
      admin: admin_from_groups(extra_data&.dig(:groups)),
      team: assign_team_from_attributes(extra_data)
    )

    user
  end

  # Profile completion tracking
  def profile_completed?
    profile_completed_at.present?
  end

  def needs_profile_completion?
    !profile_completed?
  end

  private

  def self.parse_hire_date(date_string)
    return nil if date_string.blank?
    Date.parse(date_string)
  rescue Date::Error
    nil
  end

  def self.map_title_to_role(title)
    return "Staff" if title.blank?

    case title.downcase
    when /director|vp|vice president|chief/ then "Executive"
    when /manager|lead|principal|supervisor/ then "Manager"
    when /senior|sr\.?/ then "Staff"
    else "Staff"
    end
  end

  def self.admin_from_groups(groups)
    return false if groups.blank?

    admin_groups = [ "IT-Admins", "IT-Managers", "Administrators" ]
    admin_groups.any? { |group| groups.include?(group) }
  end

  def self.assign_team_from_attributes(extra_data)
    return Team.first if extra_data.blank?

    # Priority 1: Direct group mapping
    team_mapping = {
      "IT-Development" => "Development Team",
      "IT-Infrastructure" => "Operations Team",
      "IT-Security" => "Security Team",
      "IT-Support" => "Support Team"
    }

    if extra_data[:groups]
      team_groups = extra_data[:groups] & team_mapping.keys
      team = Team.find_by(name: team_mapping[team_groups.first]) if team_groups.any?
      return team if team
    end

    # Priority 2: Department mapping
    if extra_data[:department]
      team = Team.find_by(name: "#{extra_data[:department]} Team")
      return team if team
    end

    # Fallback: First available team
    Team.first
  end
end
