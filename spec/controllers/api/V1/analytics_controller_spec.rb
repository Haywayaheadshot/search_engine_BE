require 'rails_helper'

RSpec.describe Api::V1::AnalyticsController, type: :request do
  describe 'GET /api/v1/analytics' do
    let!(:search_query) { SearchQuery.create!(query: 'Hello', content: 'Hello', count: 0) }
    let!(:log1) { SearchLog.create!(search_query: search_query, words: ['hello'], ip: '127.0.0.1') }
    let!(:log2) { SearchLog.create!(search_query: search_query, words: ['world', 'hello'], ip: '127.0.0.1') }
    let!(:log3) { SearchLog.create!(search_query: search_query, words: ['hello'], ip: '127.0.0.2') }

    context 'when ip is passed explicitly' do
      it 'returns analytics for the given IP' do
        get '/api/v1/analytics', params: { ip: '127.0.0.1' }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['ip']).to eq('127.0.0.1')
        expect(json['total_logs']).to eq(2)
        expect(json['most_searched_words']).to include('hello' => 2)
        expect(json['most_searched_queries']).to include('Hello' => 2)
      end
    end

    context 'when ip is missing' do
      it 'returns a 400 bad request with error message' do
        get '/api/v1/analytics'

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)

        expect(json['error']).to eq('IP address is required')
      end
    end
  end
end
