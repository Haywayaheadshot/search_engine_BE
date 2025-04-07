module Api
  module V1
    class SearchController < ApplicationController
      before_action :validate_query, only: :create

      def index
        search_queries = SearchQuery.order(created_at: :desc).limit(10)
        presenter = AnalyticsPresenter.new(search_queries)
        render json: presenter.as_json, status: :ok
      rescue StandardError => e
        Rails.logger.error("Analytics retrieval error: #{e.message}")
        render json: { error: 'Failed to retrieve analytics. Please try again later.' },
               status: :internal_server_error
      end

      def create
        AnalyticsService.record_search(query, ip)
        render json: { message: 'Search recorded successfully.' }, status: :ok
      rescue StandardError => e
        Rails.logger.error("Search error: #{e.message}")
        render json: { error: 'Search failed. Please try again later.' },
               status: :internal_server_error
      end

      private

      def validate_query
        return unless query.blank? || query.length < 3

        render json: { error: 'Invalid query. Query must be at least 3 characters long.' },
               status: :bad_request and return
      end

      def query
        params[:q]
      end

      def ip
        params[:ip] || request.remote_ip
      end
    end
  end
end
