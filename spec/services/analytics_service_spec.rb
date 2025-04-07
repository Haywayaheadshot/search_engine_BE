require 'rails_helper'
require 'redis'

RSpec.describe AnalyticsService, type: :service do
  let(:query) { "Hello+world" }
  let(:ip) { "127.0.0.1" }

  describe ".record_search" do
    context "when USE_REDIS_FOR_ANALYTICS is true" do
      before do
        allow(ENV).to receive(:[]).with('USE_REDIS_FOR_ANALYTICS').and_return('true')
      end

      it "calls record_in_redis" do
        expect(AnalyticsService).to receive(:record_in_redis).with(query, ip)
        AnalyticsService.record_search(query, ip)
      end
    end

    context "when USE_REDIS_FOR_ANALYTICS is false" do
      before do
        allow(ENV).to receive(:[]).with('USE_REDIS_FOR_ANALYTICS').and_return('false')
      end

      it "enqueues FindRecordsJob" do
        expect(FindRecordsJob).to receive(:perform_later).with(query, ip)
        AnalyticsService.record_search(query, ip)
      end
    end
  end

  describe ".record_in_redis" do
    let(:redis_instance) { instance_double(Redis) }
    
    before do
      allow(Redis).to receive(:new).and_return(redis_instance)
    end
    
    it "increments the search query counter, adds the IP, stores transformed content and words" do
      expect(redis_instance).to receive(:incr).with("analytics:search_query:#{query}:count")
      expect(redis_instance).to receive(:set).with("analytics:search_log:#{query}:ip", ip)
      expect(redis_instance).to receive(:set).with("analytics:search_query:#{query}:content", "Hello world")
      expect(redis_instance).to receive(:set).with("analytics:search_log:#{query}:words", '["hello","world"]')
    
      AnalyticsService.record_in_redis(query, ip)
    end
  
    context "when the query contains stop words" do
      let(:query) { "What+is+the+best+test" }
      it "skips stop words and increments only for allowed words" do
        expect(redis_instance).to receive(:incr).with("analytics:search_query:#{query}:count")
        expect(redis_instance).to receive(:set).with("analytics:search_log:#{query}:ip", ip)
        expect(redis_instance).to receive(:set).with("analytics:search_query:#{query}:content", "What is the best test")
        expect(redis_instance).to receive(:set).with("analytics:search_log:#{query}:words", '["best","test"]')

        AnalyticsService.record_in_redis(query, ip)
      end
    end
  end
  
  describe "database changes when using the background job" do
    before do
      allow(ENV).to receive(:[]).with('USE_REDIS_FOR_ANALYTICS').and_return('false')
      ActiveJob::Base.queue_adapter = :inline
    end
  
    after do
      SearchLog.delete_all
      SearchQuery.delete_all
    end
  
    it "creates a SearchQuery and SearchLog record with transformed content" do
      expect {
        AnalyticsService.record_search(query, ip)
      }.to change { SearchQuery.count }.by(1)
         .and change { SearchLog.count }.by(1)
  
      search_query = SearchQuery.find_by(query: query)
      expect(search_query).to be_present
      expect(search_query.count).to eq(1)
      expect(search_query.content).to eq("Hello world")
  
      search_log = SearchLog.find_by(search_query: search_query)
      expect(search_log).to be_present
      expect(search_log.words).to match_array(["hello", "world"])
      expect(search_log.ip).to eq(ip)
    end
  end
end
