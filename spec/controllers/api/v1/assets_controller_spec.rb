require 'rails_helper'

RSpec.describe Api::V1::AssetsController, type: :controller do
  let(:user) { create(:user, latitude: 37.7749, longitude: -122.4194) }
  let(:quest) { create(:quest, latitude: 37.7749, longitude: -122.4194) }
  let(:asset) { create(:asset) }
  let!(:quest_asset) do
    create(:quest_asset,
           quest: quest,
           asset: asset,
           latitude: 37.7749,
           longitude: -122.4194)
  end
  let!(:quest_participant) { create(:quest_participant, user: user, quest: quest) }

  describe "GET #index" do
    it "returns a successful response" do
      get :index, params: { user_id: user.id }
      expect(response).to have_http_status(:success)
    end

    it "returns user's collected assets" do
      # Collect an asset first
      quest_asset.update!(
        status: 'collected',
        collected_by_id: user.id,
        collected_at: Time.current
      )

      get :index, params: { user_id: user.id }
      expect(JSON.parse(response.body)['assets'].length).to eq(1)
    end

    it "returns empty array for user with no assets" do
      get :index, params: { user_id: user.id }
      expect(JSON.parse(response.body)['assets']).to be_empty
    end
  end

  describe "POST #collect" do
    context "when user is close enough to asset" do
      it "collects the asset" do
        post :collect, params: { id: asset.id, user_id: user.id, quest_id: quest.id }
        expect(response).to have_http_status(:success)
        expect(quest_asset.reload.status).to eq('collected')
        expect(quest_asset.collected_by_id).to eq(user.id)
      end

      it "returns success message with asset details" do
        post :collect, params: { id: asset.id, user_id: user.id, quest_id: quest.id }
        response_body = JSON.parse(response.body)
        expect(response_body['status']).to eq('success')
        expect(response_body['asset']).to include(
          'id' => asset.id,
          'name' => asset.name,
          'content' => asset.content
        )
      end
    end

    context "when user is too far from asset" do
      before do
        user.update!(latitude: 38.0, longitude: -123.0) # Far from asset
      end

      it "does not collect the asset" do
        post :collect, params: { id: asset.id, user_id: user.id, quest_id: quest.id }
        expect(response).to have_http_status(:forbidden)
        expect(quest_asset.reload.status).to eq('available')
      end
    end

    context "when user hasn't joined the quest" do
      before do
        quest_participant.destroy
      end

      it "returns forbidden status" do
        post :collect, params: { id: asset.id, user_id: user.id, quest_id: quest.id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST #place" do
    before do
      quest_asset.update!(
        status: 'collected',
        collected_by_id: user.id,
        collected_at: Time.current
      )
    end

    context "when placement is within quest boundaries" do
      let(:valid_placement) do
        {
          user_id: user.id,
          quest_id: quest.id,
          latitude: 37.7749,
          longitude: -122.4194
        }
      end

      it "places the asset" do
        post :place, params: { id: asset.id, **valid_placement }
        expect(response).to have_http_status(:success)
        expect(quest_asset.reload.status).to eq('placed')
      end

      it "returns success message with asset details" do
        post :place, params: { id: asset.id, **valid_placement }
        response_body = JSON.parse(response.body)
        expect(response_body['status']).to eq('success')
        expect(response_body['asset']).to include(
          'id' => asset.id,
          'name' => asset.name,
          'content' => asset.content,
          'status' => 'placed'
        )
      end
    end

    context "when placement is outside quest boundaries" do
      let(:invalid_placement) do
        {
          user_id: user.id,
          quest_id: quest.id,
          latitude: 40.0,
          longitude: -125.0
        }
      end

      it "does not place the asset" do
        post :place, params: { id: asset.id, **invalid_placement }
        expect(response).to have_http_status(:forbidden)
        expect(quest_asset.reload.status).to eq('collected')
      end
    end

    context "when asset is not collected by user" do
      before do
        quest_asset.update!(collected_by_id: create(:user).id)
      end

      it "returns not found status" do
        post :place, params: {
          id: asset.id,
          user_id: user.id,
          quest_id: quest.id,
          latitude: 37.7749,
          longitude: -122.4194
        }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end 