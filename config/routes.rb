Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do

      # Retrieve all quotes
      get 'quotes', to: 'quotes#index'

      # Retrieve all liked quotes
      get 'quote/liked', to: 'quotes#liked'

      # Retrieve a single quote by its id
      get 'quote/:id', to: 'quotes#show'

      # Like a specific quote
      patch 'quote/:id/like', to: 'quotes#like'

      # Retrieve a random quote by post with a list of ids to exclude in the body
      post 'quote', to: 'quotes#random'

      # Retrieve a random quote
      get 'quote', to: 'quotes#random'


    end
  end
end
