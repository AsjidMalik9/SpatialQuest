require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { { latitude: 37.7749, longitude: -122.4194 } }
  let(:invalid_attributes) { { latitude: 200.0, longitude: 500.0 } }

  describe "GET #index" do
    it "returns all users" do
      create_list(:user, 3)
      user
      get :index
      expect(JSON.parse(response.body).length).to eq(4)
    end
  end

  describe "GET #show" do
    it "returns the requested user" do
      get :show, params: { id: user.id }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['id']).to eq(user.id)
    end
  end

  describe "GET #joined_quests" do
    let(:quest) { create(:quest) }
    let!(:quest_participant) { create(:quest_participant, user: user, quest: quest) }

    it "returns user's active quests" do
      get :joined_quests, params: { id: user.id }
      expect(response).to have_http_status(:success)
      response_body = JSON.parse(response.body)
      expect(response_body['status']).to eq('success')
      expect(response_body['quests'].length).to eq(1)
      expect(response_body['quests'].first).to include(
        'id' => quest.id,
        'name' => quest.name
      )
      expect(response_body['quests'].first).to have_key('joined_at')
    end
  end

  describe "PATCH #update_location" do
    context "with valid parameters" do
      it "updates the user's location" do
        patch :update_location, params: { id: user.id, **valid_attributes }
        user.reload
        expect(user.latitude).to eq(valid_attributes[:latitude])
        expect(user.longitude).to eq(valid_attributes[:longitude])
      end

      it "returns success message" do
        patch :update_location, params: { id: user.id, **valid_attributes }
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)['message']).to eq('Location updated successfully')
      end
    end
  end
end 