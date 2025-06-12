require "test_helper"

class TeamTest < ActiveSupport::TestCase
  test "should create team with valid attributes" do
    team = Team.new(name: "Engineering")
    assert team.valid?
    assert team.save
  end

  test "should require name" do
    team = Team.new
    assert_not team.valid?
    assert team.errors[:name].present?
  end

  test "should enforce unique name" do
    Team.create!(name: "Engineering")
    duplicate_team = Team.new(name: "Engineering")
    assert_not duplicate_team.valid?
    assert duplicate_team.errors[:name].present?
  end

  test "should allow parent team" do
    parent = Team.create!(name: "Information Technology")
    child = Team.new(name: "Engineering", parent_team: parent)
    assert child.valid?
    assert child.save
    assert_equal parent, child.parent_team
  end

  test "should have child teams" do
    parent = Team.create!(name: "Information Technology")
    child1 = Team.create!(name: "Engineering", parent_team: parent)
    child2 = Team.create!(name: "Support", parent_team: parent)
    
    assert_includes parent.child_teams, child1
    assert_includes parent.child_teams, child2
    assert_equal 2, parent.child_teams.count
  end

  test "full_name should show hierarchy" do
    parent = Team.create!(name: "Information Technology")
    child = Team.create!(name: "Engineering", parent_team: parent)
    grandchild = Team.create!(name: "Network Engineering", parent_team: child)
    
    assert_equal "Information Technology", parent.full_name
    assert_equal "Information Technology → Engineering", child.full_name
    assert_equal "Information Technology → Engineering → Network Engineering", grandchild.full_name
  end

  test "top_level scope should return teams without parents" do
    initial_count = Team.top_level.count
    parent = Team.create!(name: Faker::Company.name)
    Team.create!(name: Faker::Company.name, parent_team: parent)
    orphan = Team.create!(name: Faker::Company.name)
    
    top_level_teams = Team.top_level
    assert_includes top_level_teams, parent
    assert_includes top_level_teams, orphan
    assert_equal initial_count + 2, top_level_teams.count
  end

  test "all_descendants should return nested descendants" do
    it = Team.create!(name: Faker::Company.name)
    eng = Team.create!(name: Faker::Company.name, parent_team: it)
    net = Team.create!(name: Faker::Company.name, parent_team: eng)
    sys = Team.create!(name: Faker::Company.name, parent_team: eng)
    
    descendants = it.all_descendants
    assert_includes descendants, eng
    assert_includes descendants, net
    assert_includes descendants, sys
    assert_equal 3, descendants.length
  end

  test "should restrict deletion when users exist" do
    team = Team.create!(name: "Engineering")
    user = User.create!(
      first_name: "John",
      last_name: "Doe", 
      email: "john@example.com",
      role: "Staff",
      team: team,
      password: "password"
    )
    
    assert_not team.destroy
    assert team.errors.present?
  end

  test "should restrict deletion when child teams exist" do
    parent = Team.create!(name: "Information Technology")
    Team.create!(name: "Engineering", parent_team: parent)
    
    assert_not parent.destroy
    assert parent.errors.present?
  end
end
