module Api
    module V1
      class AnalyticsController < BaseController
        before_action :validate_ip

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
      end
    end
  end
  