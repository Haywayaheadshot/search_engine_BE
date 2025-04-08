require 'rails_helper'

RSpec.describe AnalyticsPresenter do
  describe '#as_json' do
    let(:search_query) do
      SearchQuery.create!(query: 'hello', content: 'Hello world', count: 2, created_at: Time.new(2024, 1, 1, 12, 0))
    end

    let!(:log1) { SearchLog.create!(search_query: search_query, words: %w[hello world], ip: '192.168.1.1') }
    let!(:log2) { SearchLog.create!(search_query: search_query, words: %w[hello test], ip: '192.168.1.1') }

    subject { described_class.new([log1, log2]).as_json }

    it 'returns the correct IP' do
      expect(subject[:ip]).to eq('192.168.1.1')
    end

    it 'returns total_logs count' do
      expect(subject[:total_logs]).to eq(2)
    end

    it 'returns most_searched_words with duplicates only' do
      expect(subject[:most_searched_words]).to eq({ 'hello' => 2 })
    end

    it 'returns most_searched_queries with correct frequency' do
      expect(subject[:most_searched_queries]).to eq({ 'hello' => 2 })
    end

    it 'returns grouped queries with correct fields' do
      query_data = subject[:queries].first

      expect(query_data['query']).to eq('hello')
      expect(query_data['content']).to eq('Hello world')
      expect(query_data['count']).to eq(2)
      expect(query_data['ip']).to eq('192.168.1.1')
      expect(query_data['date']).to eq('2024-01-01 12:00')
    end
  end
end
