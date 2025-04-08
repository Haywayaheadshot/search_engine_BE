module Api
  module V1
    class SearchController < BaseController
      before_action :validate_query, only: :create
      before_action :validate_ip, only: :create

      def create
        AnalyticsService.record_search(query, ip)
        render json: { message: 'Search recorded successfully.', status: 200 }, status: :ok
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

      def validate_ip
        return if params[:ip].present?

        render json: { error: 'IP address is required' }, status: :bad_request and return
      end

      def ip
        params[:ip]
      end
    end
  end
end
