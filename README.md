# Ruby on Rails backend for the Quote app
This application can serve as the API backend for the React frontend which is available at:
https://github.com/edwinbulter/quote-web

When launched, the API can be tested in IntelliJ using the file quote_api_test.http which can be found in the test folder.

## Implemented features:
- A set of quotes will be requested at ZenQuotes and written in the default python sqlite database if the database is empty
- Only unique quotes are written to the database:
  - if the quoteText/author combination doesn't appear in the database, it is added
- When requesting a random quote, 'quote ids to exclude' can be sent in the body of the POST request to avoid sending the same quote again when requesting a random quote
- If the list with 'quote ids to exclude' exceeds the number of quotes in the database:
  - a set of quotes is requested at ZenQuotes, added to the database and a random new quote is returned
- Liking of quotes
  - Liked quotes will get their likes field incremented
- A list with liked quotes sorted by the number of likes can be requested.

## Project setup:
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
  - Add to gemfile: gem 'rack-cors'
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

## Running tests
Update the test db:
  ```shell
    rails db:migrate RAILS_ENV=test
  ```

Run one test:
```shell
  rails test test/controllers/api/v1/quotes_controller_test.rb
```

Run all tests:
```shell
  rails test
```

## Testing with the frontend
- Start this project from the commandline with
```shell
   rails server -p 3100
```
- Get the frontend code from https://github.com/edwinbulter/quote-web 
- Change the portnumber into 3100 in the .env.development file of the frontend:
```
   REACT_APP_API_BASE_URL=http://localhost:3100
```
- Start the frontend from the commandline with 
```shell
   npm start
```
