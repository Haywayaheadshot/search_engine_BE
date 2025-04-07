require 'rails_helper'

RSpec.describe SearchQuery, type: :model do
  subject { described_class.new(query: 'Unique query', content: 'Unique query', count: 1) }

  it { is_expected.to have_many(:search_logs).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:query) }
  it { is_expected.to validate_uniqueness_of(:query) }
  it { is_expected.to validate_numericality_of(:count).is_greater_than_or_equal_to(0) }

  describe 'dependent destroy' do
    let!(:search_query) { SearchQuery.create!(query: 'Hello', content: 'Hello', count: 0) }
    let!(:log1) { SearchLog.create!(search_query: search_query, words: ['hello'], ip: '127.0.0.1') }
    let!(:log2) { SearchLog.create!(search_query: search_query, words: ['world'], ip: '127.0.0.2') }

    it 'destroys associated search_logs when the search_query is deleted' do
      expect { search_query.destroy }.to change { SearchLog.count }.by(-2)
    end
  end
end
