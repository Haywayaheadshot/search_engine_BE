require 'rails_helper'

RSpec.describe Api::V1::AnalyticsController, type: :request do
  describe 'GET /api/v1/analytics' do
    let!(:search_query) { SearchQuery.create!(query: 'Hello', content: 'Hello', count: 0) }
    let!(:log1) { SearchLog.create!(search_query: search_query, words: ['hello'], ip: '127.0.0.1') }
    let!(:log2) { SearchLog.create!(search_query: search_query, words: %w[world hello], ip: '127.0.0.1') }
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

  describe 'PUT /api/v1/analytics/update' do
    let!(:search_query) { SearchQuery.create!(query: 'Hello', content: 'Hello', count: 1) }
    let!(:log1) { SearchLog.create!(search_query: search_query, words: ['hello'], ip: '127.0.0.1') }

    context 'when the IP has previous search queries' do
      it 'updates the search query and search log' do
        put '/api/v1/analytics/update', params: { q: 'Hello World', ip: '127.0.0.1' }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['message']).to eq('Search query updated successfully.')

        search_query.reload
        expect(search_query.query).to eq('Hello World')
        expect(search_query.content).to eq('Hello World')

        search_log = SearchLog.where(ip: '127.0.0.1').last
        expect(search_log.words).to include('world')
        expect(search_log.words).to include('hello')
      end
    end

    context 'when there is no previous search for the IP' do
      it 'returns a 404 not found with error message' do
        put '/api/v1/analytics/update', params: { q: 'New Query', ip: '127.0.0.2' }

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)

        expect(json['error']).to eq('No previous search found for this IP')
      end
    end

    context 'when the query is invalid (too short)' do
      it 'returns a 400 bad request with error message' do
        put '/api/v1/analytics/update', params: { q: 'Hi', ip: '127.0.0.1' }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)

        expect(json['error']).to eq('Invalid query. Query must be at least 3 characters long.')
      end
    end
  end
end
