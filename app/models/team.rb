class Team < ApplicationRecord
  has_many :users, dependent: :restrict_with_error
  has_many :child_teams, class_name: "Team", foreign_key: "parent_id", dependent: :restrict_with_error
  belongs_to :parent_team, class_name: "Team", foreign_key: "parent_id", optional: true

  validates :name, presence: true, uniqueness: true

  scope :top_level, -> { where(parent_id: nil) }
  scope :with_hierarchy, -> { includes(:parent_team, :child_teams) }

  def full_name
    return name if parent_team.nil?
    "#{parent_team.full_name} → #{name}"
  end

  def all_descendants
    child_teams + child_teams.flat_map(&:all_descendants)
  end
end
