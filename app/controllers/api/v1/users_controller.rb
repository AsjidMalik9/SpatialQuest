module Api
  module V1
    class UsersController < ApplicationController
      def update_location
        if current_user.update(location_params)
          render json: { 
            status: 'success',
            latitude: current_user.latitude,
            longitude: current_user.longitude
          }
        else
          render json: { status: 'error', message: current_user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def location_params
        params.require(:user).permit(:latitude, :longitude)
      end
    end
  end
end 