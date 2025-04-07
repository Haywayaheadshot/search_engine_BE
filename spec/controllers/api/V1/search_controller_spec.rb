require 'rails_helper'

RSpec.describe 'Api::V1::Search', type: :request do
  describe 'GET /api/v1/search' do
    before do
      query1 = SearchQuery.create!(query: 'Hello+world', content: 'Hello world', count: 3)
      query2 = SearchQuery.create!(query: 'What+is+the+best+test', content: 'What is the best test', count: 2)
      SearchLog.create!(search_query: query1, words: %w[hello world], ip: '127.0.0.1')
      SearchLog.create!(search_query: query1, words: %w[hello world], ip: '127.0.0.2')
      SearchLog.create!(search_query: query2, words: %w[best test], ip: '127.0.0.3')
    end

    it 'returns aggregated analytics data' do
      get '/api/v1/search'
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(2)
      first = json.first
      expect(first).to have_key('content')
      expect(first).to have_key('count')
      expect(first).to have_key('words')
      expect(first).to have_key('ips')
    end

    context 'when an error occurs' do
      before do
        allow(SearchQuery).to receive(:order).and_raise(StandardError.new('Unexpected error'))
      end

      it 'returns an internal server error' do
        get '/api/v1/search'
        expect(response).to have_http_status(:internal_server_error)
        json = JSON.parse(response.body)
        expect(json).to have_key('error')
      end
    end
  end

  describe 'POST /api/v1/search' do
    context 'with valid parameters' do
      let(:valid_params) { { q: 'Hello+world', ip: '127.0.0.1' } }

      it 'records the search and returns a success message' do
        expect(AnalyticsService).to receive(:record_search).with('Hello+world', '127.0.0.1')
        post '/api/v1/search', params: valid_params
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['message']).to eq('Search recorded successfully.')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { q: '', ip: '127.0.0.1' } }

      it 'returns a bad request error' do
        post '/api/v1/search', params: invalid_params
        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Invalid query. Query must be at least 3 characters long.')
      end
    end

    context 'when an error occurs' do
      let(:valid_params) { { q: 'Hello+world', ip: '127.0.0.1' } }
      before do
        allow(AnalyticsService).to receive(:record_search).and_raise(StandardError.new('Unexpected error'))
      end

      it 'returns an internal server error' do
        post '/api/v1/search', params: valid_params
        expect(response).to have_http_status(:internal_server_error)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Search failed. Please try again later.')
      end
    end
  end
end
