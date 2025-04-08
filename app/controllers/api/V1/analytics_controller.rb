module Api
  module V1
    class AnalyticsController < ApplicationController
      before_action :validate_ip, only: %i[index update]
      before_action :validate_query, only: :update

      def index
        user_ip = ip
        logs = SearchLog.includes(:search_query)
          .where(ip: user_ip)
          .order(created_at: :desc)

        presenter = AnalyticsPresenter.new(logs)
        render json: presenter.as_json, status: :ok
      rescue StandardError => e
        Rails.logger.error("Analytics retrieval error: #{e.message}")
        render json: { error: 'Failed to retrieve analytics. Please try again later.' },
               status: :internal_server_error
      end

      def update
        user_ip = ip
        new_query = query
        new_content = query.gsub('+', ' ')

        search_log = SearchLog.includes(:search_query).where(ip: user_ip)
        last_user_search_query = search_log.order(created_at: :desc).first

        if last_user_search_query
          last_search_query = last_user_search_query.search_query

          last_search_query.update(query: new_query, content: new_content)

          words = new_content.split.map do |word|
            normalized = word.downcase.strip
            normalized unless AnalyticsService::STOP_WORDS.include?(normalized) || normalized.blank?
          end.compact

          updated_words = last_user_search_query.words + words

          last_user_search_query.update(words: updated_words)

          render json: { message: 'Search query updated successfully.', status: 200 }, status: :ok
        else
          render json: { error: 'No previous search found for this IP' }, status: :not_found
        end
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
