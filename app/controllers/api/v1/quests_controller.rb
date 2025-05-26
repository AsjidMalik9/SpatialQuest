module Api
  module V1
    class QuestsController < ApplicationController
      def nearby
        user = current_user
        return render json: { error: 'User location not available' }, status: :bad_request unless user.latitude && user.longitude

        # Find quests that contain the user's location
        quests = Quest.containing_point(user.latitude, user.longitude)
                     .where(status: 'active')
                     .includes(:quest_participants)

        render json: {
          status: 'success',
          quests: quests.map { |quest| 
            {
              id: quest.id,
              name: quest.name,
              description: quest.description,
              participant_count: quest.quest_participants.count,
              is_joined: quest.quest_participants.exists?(user_id: user.id)
            }
          }
        }
      end

      def join
        quest = Quest.find(params[:id])
        
        # Check if user is within quest boundary
        unless quest.contains_point?(current_user.latitude, current_user.longitude)
          return render json: { error: 'You must be within the quest area to join' }, status: :forbidden
        end

        # Create participation record
        participation = quest.quest_participants.create(user: current_user, status: 'active')
        
        if participation.persisted?
          render json: { status: 'success', message: 'Successfully joined quest' }
        else
          render json: { status: 'error', message: participation.errors.full_messages }, status: :unprocessable_entity
        end
      end
    end
  end
end 