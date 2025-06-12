# Create teams
it_team = Team.find_or_create_by!(name: "Information Technology")
engineering_team = Team.find_or_create_by!(name: "Engineering", parent_team: it_team)
network_team = Team.find_or_create_by!(name: "Network Engineering", parent_team: engineering_team)
systems_team = Team.find_or_create_by!(name: "Systems Engineering", parent_team: engineering_team)

# Create admin user
admin_user = User.find_or_create_by!(email: "admin@example.com") do |user|
  user.first_name = "Admin"
  user.last_name = "User"
  user.role = "Executive"
  user.team = it_team
  user.password = "password"
  user.admin = true
end

# Create sample users
john = User.find_or_create_by!(email: "john.doe@example.com") do |user|
  user.first_name = "John"
  user.last_name = "Doe"
  user.role = "Manager"
  user.team = engineering_team
  user.password = "password"
  user.admin = false
end

jane = User.find_or_create_by!(email: "jane.smith@example.com") do |user|
  user.first_name = "Jane"
  user.last_name = "Smith"
  user.role = "Staff"
  user.team = network_team
  user.password = "password"
  user.admin = false
end

bob = User.find_or_create_by!(email: "bob.wilson@example.com") do |user|
  user.first_name = "Bob"
  user.last_name = "Wilson"
  user.role = "Staff"
  user.team = systems_team
  user.password = "password"
  user.admin = false
end

# Create sample schedules for current week
current_week_start = Date.current.beginning_of_week(:sunday)

[john, jane, bob].each do |user|
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
puts "Login credentials:"
puts "Admin: admin@example.com / password"
puts "Manager: john.doe@example.com / password"
puts "Staff: jane.smith@example.com / password"
puts "Staff: bob.wilson@example.com / password"