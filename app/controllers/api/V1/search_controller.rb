module Api
  module V1
    class SearchController < BaseController
      before_action :validate_query, only: :create
      before_action :validate_ip, only: :create

      def create
        puts "Query: #{query}, Ip #{ip}"
        AnalyticsService.record_search(query, ip)
        render json: { message: 'Search recorded successfully.', status: 200 }, status: :ok
      rescue StandardError => e
        Rails.logger.error("Search error: #{e.message}")
        render json: { error: 'Search failed. Please try again later.' },
               status: :internal_server_error
      end
    end
  end
end
