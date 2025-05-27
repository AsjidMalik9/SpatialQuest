Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users do
        member do
          patch :update_location
          get :joined_quests
        end
      end
      resources :quests do
        collection do
          get :nearby
        end
        member do
          post :join
          delete :leave
          get :quest_assets
        end
      end
      resources :assets do
        member do
          post :collect
          post :place
        end
      end
    end
  end
end
