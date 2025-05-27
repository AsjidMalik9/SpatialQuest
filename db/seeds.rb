# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear existing data
puts "Clearing existing data..."
QuestParticipant.destroy_all
QuestAsset.destroy_all
Asset.destroy_all
Quest.destroy_all
User.destroy_all

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

# Create assets
puts "Creating assets..."
assets = [
  {
    name: "Golden Gate Bridge View",
    content: "A beautiful view of the Golden Gate Bridge from multiple angles"
  },
  {
    name: "Financial District Center",
    content: "The heart of San Francisco's financial district, featuring iconic skyscrapers"
  },
  {
    name: "Union Square",
    content: "Famous shopping and entertainment district with historic significance"
  },
  {
    name: "Chinatown Gate",
    content: "The iconic entrance to San Francisco's Chinatown, a cultural landmark"
  },
  {
    name: "Ferry Building",
    content: "Historic ferry terminal and marketplace with stunning architecture"
  },
  {
    name: "Transamerica Pyramid",
    content: "San Francisco's iconic skyscraper, a symbol of the city's skyline"
  },
  {
    name: "Bank of America Building",
    content: "Historic banking headquarters with impressive architecture"
  },
  {
    name: "Federal Reserve Bank",
    content: "The Federal Reserve Bank of San Francisco, a key financial institution"
  }
]

assets.each do |asset_attrs|
  Asset.create!(asset_attrs)
end

# Associate assets with quests
puts "Associating assets with quests..."

# Downtown SF Quest Assets
downtown_quest_assets = [
  {
    asset: Asset.find_by(name: "Golden Gate Bridge View"),
    latitude: 37.7750,
    longitude: -122.4200,
    hint: "Look for the iconic red bridge in the distance",
    quest_specific_content: "From this vantage point in the Marina District, you can see the Golden Gate Bridge framed by the city skyline"
  },
  {
    asset: Asset.find_by(name: "Financial District Center"),
    latitude: 37.7850,
    longitude: -122.4150,
    hint: "Find the cluster of skyscrapers",
    quest_specific_content: "The heart of San Francisco's financial district, where major banks and corporations are headquartered"
  },
  {
    asset: Asset.find_by(name: "Union Square"),
    latitude: 37.7880,
    longitude: -122.4080,
    hint: "Look for the large public square with the Dewey Monument",
    quest_specific_content: "Union Square, a historic shopping and cultural hub in downtown San Francisco"
  },
  {
    asset: Asset.find_by(name: "Chinatown Gate"),
    latitude: 37.7820,
    longitude: -122.4120,
    hint: "Find the ornate gateway with Chinese characters",
    quest_specific_content: "The Dragon Gate, marking the entrance to the largest Chinatown outside of Asia"
  },
  {
    asset: Asset.find_by(name: "Ferry Building"),
    latitude: 37.7950,
    longitude: -122.3930,
    hint: "Look for the clock tower by the bay",
    quest_specific_content: "The historic Ferry Building, a transportation hub and marketplace since 1898"
  }
]

downtown_quest_assets.each do |quest_asset_attrs|
  downtown_sf.quest_assets.create!(quest_asset_attrs)
end

# Financial District Quest Assets
financial_quest_assets = [
  {
    asset: Asset.find_by(name: "Golden Gate Bridge View"),
    latitude: 37.7950,
    longitude: -122.4020,
    hint: "Look for the bridge from the top of the Transamerica Pyramid",
    quest_specific_content: "From this high vantage point in the Financial District, you can see the Golden Gate Bridge in the distance, framed by the city's modern architecture"
  },
  {
    asset: Asset.find_by(name: "Transamerica Pyramid"),
    latitude: 37.7951,
    longitude: -122.4021,
    hint: "Look for the distinctive pyramid-shaped skyscraper",
    quest_specific_content: "The Transamerica Pyramid, once the tallest building in San Francisco"
  },
  {
    asset: Asset.find_by(name: "Bank of America Building"),
    latitude: 37.7920,
    longitude: -122.4010,
    hint: "Find the massive banking headquarters",
    quest_specific_content: "The Bank of America Building, a symbol of the city's financial power"
  },
  {
    asset: Asset.find_by(name: "Federal Reserve Bank"),
    latitude: 37.7930,
    longitude: -122.4000,
    hint: "Look for the imposing federal building",
    quest_specific_content: "The Federal Reserve Bank of San Francisco, a key institution in the nation's banking system"
  },
  {
    asset: Asset.find_by(name: "Financial District Center"),
    latitude: 37.7860,
    longitude: -122.4140,
    hint: "Find the financial hub from a different angle",
    quest_specific_content: "A different perspective of the Financial District, showing its modern architecture"
  }
]

financial_quest_assets.each do |quest_asset_attrs|
  financial_district.quest_assets.create!(quest_asset_attrs)
end

puts "Seed data created successfully!"
