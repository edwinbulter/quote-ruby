require "test_helper"
require 'minitest/spec'

class Api::V1::QuotesControllerTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL

  # Group tests for the #index action
  describe 'GET #index' do
    test "should get index and return all quotes as JSON" do
      # Arrange: Create some sample Quote records
      Quote.create!(quoteText: "Test quote 1", author: "Author 1", likes: 5)
      Quote.create!(quoteText: "Test quote 2", author: "Author 2", likes: 10)

      # Act: Perform a GET request to the index action
      get '/api/v1/quotes'

      # Assert: Verify the response
      assert_response :success
      quotes = JSON.parse(response.body)
      assert_equal 2, quotes.count
      assert_equal "Test quote 1", quotes[0]["quoteText"]
      assert_equal "Author 1", quotes[0]["author"]
      assert_equal 5, quotes[0]["likes"]
      assert_equal "Test quote 2", quotes[1]["quoteText"]
      assert_equal "Author 2", quotes[1]["author"]
      assert_equal 10, quotes[1]["likes"]
    end
  end

  # Group tests for the #liked action
  describe 'GET #liked' do
    # Test to ensure the liked method returns quotes with likes greater than 0
    test 'should return liked quotes' do
      Quote.create(quoteText: 'Liked Quote 1', author: 'Author 1', likes: 5)
      Quote.create(quoteText: 'Liked Quote 2', author: 'Author 2', likes: 1)
      Quote.create(quoteText: 'Unliked Quote', author: 'Author 3', likes: 0)

      # Make the request to the liked endpoint
      get '/api/v1/quote/liked'

      # Assertions
      assert_response :success
      liked_quotes = JSON.parse(response.body)
      assert_equal 2, liked_quotes.length # Ensure only the liked quotes are returned

      # Check that both liked quotes are included in the response
      assert_includes liked_quotes.map { |quote| quote.slice('quoteText', 'author', 'likes') }, { 'quoteText' => 'Liked Quote 1', 'author' => 'Author 1', 'likes' => 5 }.stringify_keys
      assert_includes liked_quotes.map { |quote| quote.slice('quoteText', 'author', 'likes') }, { 'quoteText' => 'Liked Quote 2', 'author' => 'Author 2', 'likes' => 1 }.stringify_keys

      # Ensure the unliked quote is not in the response
      liked_quotes.each do |quote|
        assert quote['likes'] > 0
      end
    end

    # Test to ensure the method returns an empty array when there are no liked quotes
    test 'should return empty array when no quotes are liked' do
      Quote.create(quoteText: 'Quote 1', author: 'Author 1', likes: 0)
      Quote.create(quoteText: 'Quote 2', author: 'Author 2', likes: 0)
      Quote.create(quoteText: 'Quote 3', author: 'Author 3', likes: 0)

      # Make the request to the liked endpoint
      get '/api/v1/quote/liked'

      # Parse the JSON response
      json_response = JSON.parse(response.body)

      # Assertions
      assert_response :success
      assert_equal [], json_response # Ensure the response is an empty array
    end
  end

  # Group tests for the #show action
  describe 'GET #show' do
    # Test that the show method returns the correct quote
    test 'should show a quote by ID' do
      quote = Quote.create!(quoteText: 'Test Quote', author: 'Test Author', likes: 10)

      # Make a GET request to the show endpoint with a valid quote ID
      get "/api/v1/quote/#{quote.id}"

      # Parse the JSON response
      json_response = JSON.parse(response.body)

      # Assertions
      assert_response :success
      assert_equal quote.quoteText, json_response['quoteText']
      assert_equal quote.author, json_response['author']
      assert_equal quote.likes, json_response['likes']
    end

    # Test that the show method returns a 404 for an invalid ID
    test 'should return 404 when quote ID is not found' do
      Quote.create!(quoteText: 'Test Quote', author: 'Test Author', likes: 10)

      # Make a GET request to the show endpoint with an invalid ID
      get '/api/v1/quote/0'

      # Parse the JSON response
      json_response = JSON.parse(response.body)

      # Assertions
      assert_response :not_found
      assert_equal 'Quote not found', json_response['error']
    end
  end

  # Group tests for the #random action
  describe 'GET #random' do
    # Test that the random method returns a valid random quote
    test 'should return a random quote' do
      quote1 = Quote.create!(quoteText: 'Random Quote 1', author: 'Author 1', likes: 10)
      quote2 = Quote.create!(quoteText: 'Random Quote 2', author: 'Author 2', likes: 5)
      quote3 = Quote.create!(quoteText: 'Random Quote 3', author: 'Author 3', likes: 2)

      # Make a GET request to the random endpoint
      get '/api/v1/quote'

      # Parse the JSON response
      json_response = JSON.parse(response.body)

      # Assertions
      assert_response :success

      # The response should include a valid quote from the database
      assert_includes [quote1.quoteText, quote2.quoteText, quote3.quoteText], json_response['quoteText']
      assert_includes [quote1.author, quote2.author, quote3.author], json_response['author']

      # Ensure that the quote includes the likes field
      assert json_response['likes'].is_a?(Integer)
    end

    # Test random with excluded IDs list
    test 'should return a random quote excluding specified IDs' do
      quote1 = Quote.create!(quoteText: 'Random Quote 1', author: 'Author 1', likes: 10)
      quote2 = Quote.create!(quoteText: 'Random Quote 2', author: 'Author 2', likes: 5)
      quote3 = Quote.create!(quoteText: 'Random Quote 3', author: 'Author 3', likes: 2)

      excluded_ids = [quote1.id, quote2.id] # Exclude the first two quotes

      # Make a POST request to the random endpoint with excluded IDs
      post '/api/v1/quote', params: excluded_ids.to_json, headers: { 'Content-Type': 'application/json' }

      # Parse the JSON response
      json_response = JSON.parse(response.body)

      # Assertions
      assert_response :success

      # Ensure the returned quote is not in the excluded list
      refute_includes excluded_ids, json_response['id']

      # Ensure the returned quote is a valid quote from the database
      assert_includes [quote3.quoteText], json_response['quoteText']
      assert_equal quote3.author, json_response['author']
    end
  end

  # Group tests for the #like action
  describe 'GET #like' do
    # Test for liking a quote successfully
    test 'should increment likes for a valid quote' do
      quote = Quote.create!(quoteText: 'This is a test quote', author: 'Test Author', likes: 0)

      # Make a POST request to the like endpoint
      patch "/api/v1/quote/#{quote.id}/like"

      # Reload the quote to see updated data
      quote.reload

      # Parse the JSON response
      json_response = JSON.parse(response.body)

      # Assertions
      assert_response :success
      assert_equal 1, quote.likes         # Likes should increase by 1
      assert_equal quote.likes, json_response # Response should contain the updated likes count
    end
  end
end
