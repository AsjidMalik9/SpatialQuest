# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Clear existing data
puts "Clearing existing data..."
User.destroy_all
Quest.destroy_all
QuestParticipant.destroy_all

# Create sample users
puts "Creating sample users..."
users = [
  {
    email: "asjid@test.com",
    latitude: 37.7749,
    longitude: -122.4194
  },
  {
    email: "alex@test.com",
    latitude: 37.7833,
    longitude: -122.4167
  },
  {
    email: "asjid2@test.com",
    latitude: 37.7855,
    longitude: -122.4067
  }
]

users.each do |user_attrs|
  User.create!(user_attrs)
end

# Create sample quests
puts "Creating sample quests..."

# Downtown SF Quest (contains asjid and alex)
downtown_sf = Quest.create!(
  name: "Downtown San Francisco Explorer",
  status: "active",
  latitude: 37.7791,
  longitude: -122.4180,
  boundary: {
    type: "Polygon",
    coordinates: [[
      [-122.4250, 37.7700],  # Southwest
      [-122.4250, 37.7900],  # Northwest
      [-122.4100, 37.7900],  # Northeast
      [-122.4100, 37.7700],  # Southeast
      [-122.4250, 37.7700]   # Back to start
    ]]
  }.to_json
)

# Financial District Quest (contains asjid2)
financial_district = Quest.create!(
  name: "Financial District Adventure",
  status: "active",
  latitude: 37.7855,
  longitude: -122.4067,
  boundary: {
    type: "Polygon",
    coordinates: [[
      [-122.4150, 37.7800],  # Southwest
      [-122.4150, 37.7900],  # Northwest
      [-122.4000, 37.7900],  # Northeast
      [-122.4000, 37.7800],  # Southeast
      [-122.4150, 37.7800]   # Back to start
    ]]
  }.to_json
)

puts "Seed data created successfully!"
