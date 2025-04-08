module Api
    module V1
      class BaseController < ApplicationController
        private

        def validate_ip
          unless params[:ip].present?
            render json: { error: 'IP address is required' }, status: :bad_request and return
          end
        end
        
        def ip          
          params[:ip]          
        end
      end
    end
  end
  