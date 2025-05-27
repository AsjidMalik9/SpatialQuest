module Api
  module V1
    class QuestsController < ApplicationController
      before_action :set_quest, only: [:show, :join, :leave, :quest_assets]

      def index
        if params[:lat].present? && params[:lon].present?
          @quests = Quest.active.containing_point(params[:lat].to_f, params[:lon].to_f)
          if @quests.any?
            render json: {
              status: 'success',
              quests: @quests
            }
          else
            render json: {
              status: 'success',
              message: 'No quests found in this area',
              quests: []
            }
          end
        else
          @quests = Quest.active
          render json: @quests
        end
      end

      def show
        render json: @quest
      end

      def quest_assets
        @quest_assets = @quest.quest_assets
        render json: {
          status: 'success',
          quest_name: @quest.name,
          total_assets: @quest_assets.count,
          available_assets: @quest_assets.available.count,
          collected_assets: @quest_assets.collected.count,
          placed_assets: @quest_assets.placed.count,
          assets: @quest_assets.map { |quest_asset|
            {
              id: quest_asset.asset_id,
              name: quest_asset.asset.name,
              content: quest_asset.asset.content,
              latitude: quest_asset.latitude,
              longitude: quest_asset.longitude,
              status: quest_asset.status,
              hint: quest_asset.hint,
              quest_specific_content: quest_asset.quest_specific_content,
              collected_by: quest_asset.collected_by&.email,
              collected_at: quest_asset.collected_at,
              placed_at: quest_asset.placed_at
            }
          }
        }
      end

      def nearby
        user = User.find_by(id: params[:user_id])
        unless user&.current_latitude && user&.current_longitude
          return render json: { error: 'User location not available' }, status: :bad_request
        end
        @quests = Quest.active.near_user(user)
        if @quests.any?
          render json: {
            status: 'success',
            quests: @quests.map { |quest| 
              quest.as_json.merge(
                is_joined: quest.users.include?(user)
              )
            }
          }
        else
          render json: {
            status: 'success',
            message: 'No quests found in your area',
            quests: []
          }
        end
      end

      def join
        user = User.find_by(id: params[:user_id])
        unless user&.current_latitude && user&.current_longitude
          return render json: { error: 'User location not available' }, status: :bad_request
        end
        unless @quest.contains_point?(user.current_latitude, user.current_longitude)
          return render json: { error: 'You must be within the quest boundary to join' }, status: :forbidden
        end
        if @quest.users.include?(user)
          return render json: { error: 'You have already joined this quest' }, status: :unprocessable_entity
        end
        @quest_participant = @quest.quest_participants.build(user: user, status: 'active')
        if @quest_participant.save
          render json: { message: 'Successfully joined the quest' }
        else
          render json: { error: @quest_participant.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def leave
        user = User.find_by(id: params[:user_id])
        @quest_participant = @quest.quest_participants.find_by(user: user)
        
        if @quest_participant&.leave!
          render json: { message: 'Successfully left the quest' }
        else
          render json: { error: 'Failed to leave the quest' }, status: :unprocessable_entity
        end
      end

      private

      def set_quest
        @quest = Quest.find(params[:id])
      end
    end
  end
end 