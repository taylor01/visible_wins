# Create teams
it_team = Team.find_or_create_by!(name: "Information Technology")
engineering_team = Team.find_or_create_by!(name: "Engineering", parent_team: it_team)
network_team = Team.find_or_create_by!(name: "Network Engineering", parent_team: engineering_team)
systems_team = Team.find_or_create_by!(name: "Systems Engineering", parent_team: engineering_team)

# Create admin user (OIDC format)
admin_user = User.find_or_create_by!(email: "admin@example.com") do |user|
  user.okta_sub = "admin_test_sub_123"
  user.first_name = "Admin"
  user.last_name = "User"
  user.role = "Executive"
  user.team = it_team
  user.admin = true
  user.active = true
  user.employee_id = "EMP001"
  user.title = "IT Director"
  user.department = "Information Technology"
end

# Create sample users (OIDC format)
john = User.find_or_create_by!(email: "john.doe@example.com") do |user|
  user.okta_sub = "john_test_sub_456"
  user.first_name = "John"
  user.last_name = "Doe"
  user.role = "Manager"
  user.team = engineering_team
  user.admin = false
  user.active = true
  user.employee_id = "EMP002"
  user.title = "Engineering Manager"
  user.department = "Engineering"
end

jane = User.find_or_create_by!(email: "jane.smith@example.com") do |user|
  user.okta_sub = "jane_test_sub_789"
  user.first_name = "Jane"
  user.last_name = "Smith"
  user.role = "Staff"
  user.team = network_team
  user.admin = false
  user.active = true
  user.employee_id = "EMP003"
  user.title = "Network Engineer"
  user.department = "Engineering"
  user.manager_email = "john.doe@example.com"
end

bob = User.find_or_create_by!(email: "bob.wilson@example.com") do |user|
  user.okta_sub = "bob_test_sub_012"
  user.first_name = "Bob"
  user.last_name = "Wilson"
  user.role = "Staff"
  user.team = systems_team
  user.admin = false
  user.active = true
  user.employee_id = "EMP004"
  user.title = "Systems Engineer"
  user.department = "Engineering"
  user.manager_email = "john.doe@example.com"
end

# Create sample schedules for current week
current_week_start = Date.current.beginning_of_week(:sunday)

[ john, jane, bob ].each do |user|
  WeeklySchedule.find_or_create_by!(user: user, week_start_date: current_week_start) do |schedule|
    schedule.monday = "Office"
    schedule.tuesday = "WFH"
    schedule.wednesday = "Office"
    schedule.thursday = "WFH"
    schedule.friday = "Office"
  end
end

puts "Created #{Team.count} teams"
puts "Created #{User.count} users"
puts "Created #{WeeklySchedule.count} weekly schedules"
puts ""
puts "Sample users created for OIDC testing:"
puts "Admin: admin@example.com"
puts "Manager: john.doe@example.com"
puts "Staff: jane.smith@example.com"
puts "Staff: bob.wilson@example.com"
puts ""
puts "Note: Authentication is now handled via OIDC/Okta"
