# Ruby on Rails version of the Quote app

Project setup:
- rails new quote-ruby
- open project in Intellij Idea
- create Quote model in terminal
  ```shell
  rails generate model Quote quoteText:string author:string likes:integer
  rails db:migrate
  ```
- add your routes to config/routes.rb:
  ```ruby
  Rails.application.routes.draw do
    namespace :api do
      namespace :v1 do
        resources :quotes, only: [:index] # Only allow the index action for now
      end
    end
  end
  ```
- run in the terminal
  ```shell
  rails routes
  ```
- create a controller in the terminal:
  ```shell
  rails generate controller api/v1/quotes
  ```
- create the index action in the controller:
```ruby
class Api::V1::QuotesController < ApplicationController
  def index
    @quotes = Quote.all
    render json: @quotes
  end
end
```
- to fix CORS issue when calling the API from the browser:
  - Add to gemfile: gem 'rack-cors
  - run in terminal
    ```shell
    bundle install
    ```
- add in config/application.rb
```ruby
    # CORS Configuration
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins 'http://localhost:3000', 'http://localhost:3001', 'http://localhost:3002' # Allowed origins (adjust as needed)
        resource '*', # Apply this rule to all paths/endpoints
                 headers: :any, # Allow all headers (e.g., JSON, custom headers)
                 methods: [:get, :post, :put, :patch, :delete, :options, :head], # Allow specific request methods
                 credentials: true # Allow cookies/credentials to be sent (if API requires this)
      end
    end
```