module Api
  module V1
    class BaseController < ApplicationController
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
