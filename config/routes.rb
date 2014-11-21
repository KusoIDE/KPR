Rails.application.routes.draw do

  devise_for :users
  use_doorkeeper

  namespace :api, defaults: { format: 'plain' } do
    namespace :v1 do
      get '/packages/' => 'packages#index'
      get '/packages/archive-contents' => 'packages#archive_contents'
    end
  end

  get '/packages/archive-contents' => 'api/v1/packages#archive_contents'

end
