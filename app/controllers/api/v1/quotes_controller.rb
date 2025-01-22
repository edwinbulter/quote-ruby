class Api::V1::QuotesController < ApplicationController
  include ActionController::Live

  # Rails enforces CSRF (Cross-Site Request Forgery) protection for non-GET requests (e.g., `POST`, `PATCH`, `PUT`, `DELETE`) by default.
  # To avoid the error "Can't verify CSRF token authenticity", Skip CSRF token verification for API calls
  skip_before_action :verify_authenticity_token

  def index
    quotes = Quote.all
    render json: quotes
  end

  def liked
    liked_quotes = Quote.where('likes > 0')
    render json: liked_quotes
  end

  def show
    begin
      quote = Quote.find(params[:id])
      render json: quote, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Quote not found' }, status: :not_found
    end
  end

  def like
    begin
      quote = Quote.find(params[:id])
      quote.update!(likes: quote.likes + 1)
      render plain: quote.likes, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Quote not found' }, status: :not_found
    rescue => e
      render json: { error: 'Unable to update likes', details: e.message }, status: :unprocessable_entity
    end
  end

  def random
    begin
      # Parse the array of IDs from the request body (default to empty array if none provided)
      excluded_ids = params[:_json] || [0]

      # Validate that input is an array
      unless excluded_ids.is_a?(Array)
        return render json: { error: 'Invalid input format. Expected a JSON array of IDs.' }, status: :bad_request
      end

      quote_count = Quote.count
      remaining_quote_count = Quote.where.not(id: excluded_ids).count
      Rails.logger.info("Number of quotes in the database is #{quote_count}, the number of remaining quotes is #{remaining_quote_count}")

      # Check if the number of quotes in the database is less than 10
      if remaining_quote_count < 1
        begin
          Rails.logger.info("Fetching quotes from Zen")

          # Fetch quotes from ZenQuotes API
          require 'net/http'
          require 'json'

          url = URI('https://zenquotes.io/api/quotes')
          response = Net::HTTP.get(url)
          quotes = JSON.parse(response)

          # Iterate through the fetched quotes and add them to the database
          quotes.each do |quote|

            # Only add a quote to the database if the quote/author combination doesn't occur yet
            if quote['q'] && quote['a']
              unless Quote.exists?(quoteText: quote['q'], author: quote['a'])
                Quote.create(quoteText: quote['q'], author: quote['a'], likes: 0)
              end
            end

          end
        rescue => e
          Rails.logger.error("Failed to fetch quotes from ZenQuotes: #{e.message}")
        end
      end


      # Fetch a random quote while excluding the given IDs
      quote = Quote.where.not(id: excluded_ids).order('RANDOM()').first

      # If no quotes are available, respond with an appropriate message
      if quote.nil?
        return render json: { error: 'No available quotes.' }, status: :not_found
      end

      # Respond with the random quote in JSON format
      render json: quote, status: :ok

    rescue => e
      render json: { error: 'Something went wrong', details: e.message }, status: :internal_server_error
    end
  end

end
