require 'rails_helper'

RSpec.describe SearchLog, type: :model do
  let(:search_query) { SearchQuery.create!(query: 'test+query', content: 'test query', count: 1) }
  subject { described_class.new(search_query: search_query, words: %w[test word], ip: '127.0.0.1') }

  it { is_expected.to belong_to(:search_query) }

  it { is_expected.to validate_presence_of(:ip) }

  describe 'serialization of words' do
    it 'is stored and retrieved as an array' do
      subject.words = %w[one two]
      subject.save!
      reloaded = described_class.find(subject.id)
      expect(reloaded.words).to be_an(Array)
      expect(reloaded.words).to eq(%w[one two])
    end
  end
end
