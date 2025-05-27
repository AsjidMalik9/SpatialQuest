module Api
  module V1
    class AssetsController < ApplicationController
      def index
        user = User.find(params[:user_id])
        @quest_assets = QuestAsset.where(collected_by: user)
        render json: {
          status: 'success',
          assets: @quest_assets.map { |quest_asset|
            {
              id: quest_asset.asset_id,
              name: quest_asset.asset.name,
              content: quest_asset.asset.content,
              quest_name: quest_asset.quest.name,
              status: quest_asset.status,
              collected_at: quest_asset.collected_at,
              placed_at: quest_asset.placed_at
            }
          }
        }
      end

      def collect
        user = User.find(params[:user_id])
        quest_asset = QuestAsset.find_by(
          asset_id: params[:id],
          quest_id: params[:quest_id]
        )
        
        unless quest_asset
          return render json: { error: 'Asset not found in this quest' }, status: :not_found
        end

        unless user.quests.include?(quest_asset.quest)
          return render json: { error: 'You must join the quest first' }, status: :forbidden
        end

        # Verify user is close enough to the asset
        distance = calculate_distance(
          user.current_latitude, 
          user.current_longitude,
          quest_asset.latitude,
          quest_asset.longitude
        )

        if distance > 0.1 # 100 meters
          return render json: { error: 'You must be closer to the asset to collect it' }, status: :forbidden
        end

        if quest_asset.collect!(user)
          # Check if quest is completed after collecting
          quest_asset.quest.check_completion!
          
          render json: {
            status: 'success',
            message: 'Asset collected successfully',
            asset: {
              id: quest_asset.asset_id,
              name: quest_asset.asset.name,
              content: quest_asset.asset.content,
              status: quest_asset.status,
              collected_at: quest_asset.collected_at
            },
            quest_completed: quest_asset.quest.status == 'completed'
          }
        else
          render json: { error: 'Failed to collect asset' }, status: :unprocessable_entity
        end
      end

      def place
        user = User.find(params[:user_id])
        quest_asset = QuestAsset.find_by(
          asset_id: params[:id],
          quest_id: params[:quest_id],
          collected_by: user
        )
        
        unless quest_asset
          return render json: { error: 'Asset not found or not collected by you' }, status: :not_found
        end

        # Update location before placing
        quest_asset.latitude = params[:latitude]
        quest_asset.longitude = params[:longitude]

        if quest_asset.place!
          render json: {
            status: 'success',
            message: 'Asset placed successfully',
            asset: {
              id: quest_asset.asset_id,
              name: quest_asset.asset.name,
              content: quest_asset.asset.content,
              status: quest_asset.status,
              latitude: quest_asset.latitude,
              longitude: quest_asset.longitude,
              placed_at: quest_asset.placed_at
            }
          }
        else
          render json: { error: 'Failed to place asset' }, status: :unprocessable_entity
        end
      end

      private

      def calculate_distance(lat1, lon1, lat2, lon2)
        rad_per_deg = Math::PI/180
        earth_radius = 6371 # km

        lat1_rad = lat1 * rad_per_deg
        lat2_rad = lat2 * rad_per_deg
        lon1_rad = lon1 * rad_per_deg
        lon2_rad = lon2 * rad_per_deg

        a = Math.sin((lat2_rad - lat1_rad)/2)**2 + 
            Math.cos(lat1_rad) * Math.cos(lat2_rad) * 
            Math.sin((lon2_rad - lon1_rad)/2)**2
        c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
        earth_radius * c
      end
    end
  end
end 