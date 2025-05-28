module Api
  module V1
    class UsersController < ApplicationController
      def index
        @users = User.all
        render json: @users
      end

      def show
        @user = User.find(params[:id])
        render json: @user
      end

      def update_location
        @user = User.find(params[:id])
        if @user.update_location(params[:latitude], params[:longitude])
          render json: { message: 'Location updated successfully' }
        else
          render json: { error: 'Failed to update location' }, status: :unprocessable_entity
        end
      end

      def joined_quests
        @user = User.find(params[:id])
        @quests = @user.quests.active
        render json: {
          status: 'success',
          quests: @quests.map { |quest| 
            quest.as_json.merge(
              joined_at: quest.quest_participants.find_by(user: @user).created_at
            )
          }
        }
      end

      private

      def location_params
        params.require(:user).permit(:latitude, :longitude)
      end
    end
  end
end 