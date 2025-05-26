require 'rails_helper'

RSpec.describe Api::V1::QuestsController, type: :controller do
  let(:user) { create(:user, latitude: 37.7799, longitude: -122.4144) }
  let(:campus_boundary) do
    {
      type: 'Polygon',
      coordinates: [[
        [-122.4194, 37.7749],
        [-122.4194, 37.7849],
        [-122.4094, 37.7849],
        [-122.4094, 37.7749],
        [-122.4194, 37.7749]
      ]]
    }.to_json
  end

  let!(:nearby_quest) do
    create(:quest,
      name: 'Nearby Quest',
      status: 'active',
      latitude: 37.7799,
      longitude: -122.4144,
      boundary: campus_boundary
    )
  end

  let!(:far_quest) do
    create(:quest,
      name: 'Far Quest',
      status: 'active',
      latitude: 37.7849,
      longitude: -122.4294,
      boundary: {
        type: 'Polygon',
        coordinates: [[
          [-122.4294, 37.7849],
          [-122.4294, 37.7949],
          [-122.4194, 37.7949],
          [-122.4194, 37.7849],
          [-122.4294, 37.7849]
        ]]
      }.to_json
    )
  end

  describe 'GET #nearby' do
    it 'returns nearby quests' do
      get :nearby, params: { user_id: user.id }
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      
      expect(json_response['status']).to eq('success')
      expect(json_response['quests'].length).to eq(1)
      expect(json_response['quests'][0]['name']).to eq('Nearby Quest')
    end

    it 'returns empty list when no quests are nearby' do
      user.update(latitude: 37.7949, longitude: -122.4394)
      
      get :nearby, params: { user_id: user.id }
      
      json_response = JSON.parse(response.body)
      expect(json_response['status']).to eq('success')
      expect(json_response['quests']).to be_empty
      expect(json_response['message']).to eq('No quests found in your area')
    end

    it 'includes participation status' do
      create(:quest_participant, quest: nearby_quest, user: user, status: 'active')
      
      get :nearby, params: { user_id: user.id }
      
      json_response = JSON.parse(response.body)
      expect(json_response['quests'][0]['is_joined']).to be true
    end
  end

  describe 'POST #join' do
    it 'allows user to join when inside boundary' do
      post :join, params: { id: nearby_quest.id, user_id: user.id }
      
      expect(response).to have_http_status(:success)
      expect(nearby_quest.users).to include(user)
    end

    it 'prevents joining when outside boundary' do
      user.update(latitude: 37.7949, longitude: -122.4394)
      
      post :join, params: { id: nearby_quest.id, user_id: user.id }
      
      expect(response).to have_http_status(:forbidden)
      expect(JSON.parse(response.body)['error']).to eq('You must be within the quest boundary to join')
    end

    it 'prevents joining the same quest twice' do
      create(:quest_participant, quest: nearby_quest, user: user, status: 'active')
      
      post :join, params: { id: nearby_quest.id, user_id: user.id }
      
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['error']).to eq('You have already joined this quest')
    end
  end
end 