require 'rails_helper'

RSpec.describe AnalyticsPresenter do
  let!(:search_query1) do
    sq = SearchQuery.create!(query: 'Hello+world', content: 'Hello world', count: 3)
    SearchLog.create!(search_query: sq, words: %w[hello world], ip: '127.0.0.1')
    SearchLog.create!(search_query: sq, words: %w[hello world], ip: '127.0.0.2')
    sq
  end

  let!(:search_query2) do
    sq = SearchQuery.create!(query: 'What+is+the+best+test', content: 'What is the best test', count: 2)
    SearchLog.create!(search_query: sq, words: %w[best test], ip: '127.0.0.3')
    sq
  end

  subject { AnalyticsPresenter.new([search_query1, search_query2]).as_json }

  it 'returns an array of hashes with the expected keys' do
    subject.each do |record|
      expect(record).to include('content', 'count', 'words', 'ips')
    end
  end

  it 'aggregates words with counts correctly' do
    expect(subject.first['words']).to eq({ 'hello' => 2, 'world' => 2 })
    expect(subject.last['words']).to eq({ 'best' => 1, 'test' => 1 })
  end

  it 'aggregates unique IPs correctly' do
    expect(subject.first['ips']).to match_array(['127.0.0.1', '127.0.0.2'])
    expect(subject.last['ips']).to eq(['127.0.0.3'])
  end
end
