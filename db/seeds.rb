# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
if Rails.env.development?
  puts "Seeding development database..."
  
  # 1. Admin User
  AdminUser.find_or_create_by!(email: 'admin@example.com') do |i|
    i.password = 'password'
    i.password_confirmation = 'password'
  end
  
  user1 = User.find_or_create_by!(email: 'john123@example.com') do |i|
    i.name = "John Smith"
    i.password = "12345678"
  end
  user2 = User.find_or_create_by!(email: 'rahul123@gmail.com') do |i|
    i.name = "Rahul"
    i.password = "1234567"
  end
  user3 = User.find_or_create_by!(email: 'sumit123@example.com') do |i|
    i.name = "Sumit"
    i.password = "12345678"
  end
  user4 = User.find_or_create_by!(email: 'geetika123@example.com') do |i|
    i.name = "Geetika"
    i.password = "12345678"
  end
  user5= User.find_or_create_by!(email: 'manisha@example.com') do |i|
    i.name = "Manisha"
    i.password = "12345678"
  end
  user6 = User.find_or_create_by!(email: 'sanjana123@example.com') do |i|
    i.name = "Sanjana"
    i.password = "12345678"
  end
  
  project1 = user1.projects.find_or_create_by!(name: "Rails Application") do |i|
    i.description = "A rails framework project"
    i.due_date =  Date.parse("2026-09-30")
    i.status = "in_progress"
  end
  project2 = user2.projects.find_or_create_by!(name: "java project") do |i|
    i.description = "A springboot java  project"
    i.due_date =  Date.parse("2026-10-28")
    i.status = "in_progress"
  end
  project3 = user3.projects.find_or_create_by!(name: "python project") do |i|
    i.description = " creating the python project "
    i.due_date =  Date.parse("2026-09-23")
    i.status = "in_progress"
  end
  project4 = user4.projects.find_or_create_by!(name: "E-commerce website") do |i|
    i.description = "wesite for te E-commercing"
    i.due_date =  Date.parse("2026-10-10")
    i.status = "not_started"
  end
  task1 = project1.tasks.find_or_create_by!(title: "Backend developement") do |i|
    i.description = "completing the backend development"
    i.status = "todo"
    i.priority = "medium"
    i.due_date = Date.parse("2026-09-29")
    i.creator_id= user1.id
  end
  task2 = project1.tasks.find_or_create_by!(title: "Frontend part") do |i|
    i.description = "completing the frontend development"
    i.status = "todo"
    i.priority = "low"
    i.due_date = Date.parse("2026-09-20")
    i.creator_id= user2.id
    i.assignee_id=user1.id
  end
  task3 = project2.tasks.find_or_create_by!(title: "springboot framework apllication ") do |i|
    i.description = "completing the backend development"
    i.status = "todo"
    i.priority = "high"
    i.due_date = Date.parse("2026-09-29")
    i.creator_id= user3.id
    i.assignee_id=user4.id

  end
  task4 = project2.tasks.find_or_create_by!(title: "ui/ux design") do |i|
    i.description = "creating the ui/ux of project"
    i.status = "in_progress"
    i.priority = "low"
    i.due_date = Date.parse("2026-09-24")
    i.creator_id= user5.id
    i.assignee_id=user2.id
  end
  task5 = project3.tasks.find_or_create_by!(title: "dashboard creation") do |i|
    i.description = "completing the dashboard creation"
    i.status = "in_progress"
    i.priority = "high"
    i.due_date = Date.parse("2026-09-23")
    i.creator_id= user4.id
    i.assignee_id=user3.id
  end
  task6 = project3.tasks.find_or_create_by!(title: "testing") do |i|
    i.description = "testing the APIs"
    i.status = "done"
    i.priority = "low"
    i.due_date = Date.parse("2026-09-27")
    i.creator_id= user2.id
    i.assignee_id=user5.id
  end
  task7 = project4.tasks.find_or_create_by!(title: "deployment") do |i|
    i.description = "completing the deployment"
    i.status = "todo"
    i.priority = "medium"
    i.due_date = Date.parse("2026-09-30")
    i.creator_id= user6.id
    i.assignee_id=user3.id

  end
  task8 = project4.tasks.find_or_create_by!(title: "adding the products") do |i|
    i.description = "completing the adding the product"
    i.status = "in_progress"
    i.priority = "high"
    i.due_date = Date.parse("2026-09-29")
    i.creator_id= user1.id
    i.assignee_id=user6.id

  end
end
