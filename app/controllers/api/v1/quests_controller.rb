module Api
  module V1
    class QuestsController < ApplicationController
      before_action :set_quest, only: [:show, :join]

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

      private

      def set_quest
        @quest = Quest.find(params[:id])
      end
    end
  end
end 