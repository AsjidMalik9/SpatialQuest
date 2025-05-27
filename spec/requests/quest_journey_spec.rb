require 'rails_helper'

RSpec.describe "Quest Journey", type: :request do
  let(:user) do
    User.create!(
      email: Faker::Internet.email,
      latitude: 37.7749,
      longitude: -122.4194
    )
  end

  let(:quest) do
    Quest.create!(
      name: "San Francisco Explorer",
      status: "active",
      latitude: 37.7749,
      longitude: -122.4194,
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
  end

  let(:assets) do
    [
      {
        name: "Golden Gate Bridge View",
        content: "A beautiful view of the Golden Gate Bridge"
      },
      {
        name: "Ferry Building",
        content: "Historic ferry terminal and marketplace"
      }
    ].map { |attrs| Asset.create!(attrs) }
  end

  let(:quest_assets) do
    assets.map do |asset|
      QuestAsset.create!(
        quest: quest,
        asset: asset,
        latitude: 37.7749 + rand(-0.01..0.01),
        longitude: -122.4194 + rand(-0.01..0.01),
        status: 'available',
        hint: Faker::Lorem.sentence,
        quest_specific_content: Faker::Lorem.paragraph
      )
    end
  end

  before do
    quest_assets # Initialize the quest assets
  end

  it "completes the full quest journey" do
    # 1. Join the quest
    post "/api/v1/quests/#{quest.id}/join", params: {
      user_id: user.id
    }
    expect(response).to have_http_status(:success)
    expect(JSON.parse(response.body)["message"]).to eq("Successfully joined the quest")

    # 2. Get quest assets
    get "/api/v1/quests/#{quest.id}/quest_assets"
    expect(response).to have_http_status(:success)
    assets_response = JSON.parse(response.body)
    expect(assets_response["total_assets"]).to eq(2)
    expect(assets_response["available_assets"]).to eq(2)
    expect(assets_response["collected_assets"]).to eq(0)
    expect(assets_response["placed_assets"]).to eq(0)

    # 3. Try to collect first asset from far away
    first_asset = quest_assets.first
    # Update user location to be far away
    user.update_location(37.7849, -122.4294)
    post "/api/v1/assets/#{first_asset.asset_id}/collect", params: {
      user_id: user.id,
      quest_id: quest.id
    }
    expect(response).to have_http_status(:forbidden)
    expect(JSON.parse(response.body)["error"]).to eq("You must be closer to the asset to collect it")

    # 4. Collect first asset from nearby
    # Update user location to be close to the asset
    user.update_location(first_asset.latitude, first_asset.longitude)
    post "/api/v1/assets/#{first_asset.asset_id}/collect", params: {
      user_id: user.id,
      quest_id: quest.id
    }
    expect(response).to have_http_status(:success)
    expect(JSON.parse(response.body)["message"]).to eq("Asset collected successfully")

    # 5. Place first asset at new location
    new_latitude = 37.7850
    new_longitude = -122.4150
    post "/api/v1/assets/#{first_asset.asset_id}/place", params: {
      user_id: user.id,
      quest_id: quest.id,
      latitude: new_latitude,
      longitude: new_longitude
    }
    expect(response).to have_http_status(:success)
    expect(JSON.parse(response.body)["message"]).to eq("Asset placed successfully")

    # 6. Try to collect second asset from far away
    second_asset = quest_assets.last
    # Update user location to be far away
    user.update_location(37.7849, -122.4294)
    post "/api/v1/assets/#{second_asset.asset_id}/collect", params: {
      user_id: user.id,
      quest_id: quest.id
    }
    expect(response).to have_http_status(:forbidden)
    expect(JSON.parse(response.body)["error"]).to eq("You must be closer to the asset to collect it")

    # 7. Collect second asset from nearby
    # Update user location to be close to the asset
    user.update_location(second_asset.latitude, second_asset.longitude)
    post "/api/v1/assets/#{second_asset.asset_id}/collect", params: {
      user_id: user.id,
      quest_id: quest.id
    }
    expect(response).to have_http_status(:success)
    expect(JSON.parse(response.body)["message"]).to eq("Asset collected successfully")

    # 8. Place second asset
    post "/api/v1/assets/#{second_asset.asset_id}/place", params: {
      user_id: user.id,
      quest_id: quest.id,
      latitude: new_latitude + 0.001,
      longitude: new_longitude + 0.001
    }
    expect(response).to have_http_status(:success)
    expect(JSON.parse(response.body)["message"]).to eq("Asset placed successfully")

    # 9. Check quest completion
    get "/api/v1/quests/#{quest.id}/quest_assets"
    expect(response).to have_http_status(:success)
    assets_response = JSON.parse(response.body)
    expect(assets_response["total_assets"]).to eq(2)
    expect(assets_response["available_assets"]).to eq(0)
    expect(assets_response["collected_assets"]).to eq(0)
    expect(assets_response["placed_assets"]).to eq(2)

    # 11. Leave the quest
    delete "/api/v1/quests/#{quest.id}/leave", params: {
      user_id: user.id
    }
    expect(response).to have_http_status(:success)
    expect(JSON.parse(response.body)["message"]).to eq("Successfully left the quest")

    # 12. Verify user's collected assets
    get "/api/v1/users/#{user.id}/joined_quests"
    expect(response).to have_http_status(:success)
    joined_quests = JSON.parse(response.body)
    expect(joined_quests["quests"]).to be_empty
  end
end 