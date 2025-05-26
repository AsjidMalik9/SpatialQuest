require 'rails_helper'

RSpec.describe Api::V1::QuestsController, type: :controller do
  describe 'GET #nearby' do
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

    before do
      sign_in user
    end

    it 'returns nearby quests' do
      get :nearby
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      
      expect(json_response['status']).to eq('success')
      expect(json_response['quests'].length).to eq(1)
      expect(json_response['quests'][0]['name']).to eq('Nearby Quest')
    end

    it 'returns error when user location is not available' do
      user.update(latitude: nil, longitude: nil)
      
      get :nearby
      
      expect(response).to have_http_status(:bad_request)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq('User location not available')
    end

    it 'includes participation status' do
      create(:quest_participant, quest: nearby_quest, user: user, status: 'active')
      
      get :nearby
      
      json_response = JSON.parse(response.body)
      expect(json_response['quests'][0]['is_joined']).to be true
    end
  end
end 