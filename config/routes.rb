Rails.application.routes.draw do
  root to: "organizations#show"
  devise_for :users, only: :sessions, controllers: {
    sessions: 'users/sessions'
  }
  resources :devices, only: [:create, :show, :new]
  resources :organizations, only: :show
  namespace :piaweb do
    namespace :api, defaults: {format: :json}  do
      namespace :b2b do
        namespace :v1 do
          put "devices/:dvc_name/jwk", to: "devices_activation#create"
          resources :orgs, only: [] do
            put "devices/:dvc_name/jwk", to: "refresh_device_keys#create"
          end
        end
      end
    end
  end
  namespace :mga do
    namespace :sps do
      namespace :oauth do
        namespace :oauth20, defaults: {format: :json} do
          post "token", to: "device_authentication#create"
        end
      end
    end
  end
end
