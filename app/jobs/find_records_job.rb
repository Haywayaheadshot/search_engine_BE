class FindRecordsJob < ApplicationJob
  queue_as :default

  def perform(query, ip)
    content = query.gsub('+', ' ')

    search_query = SearchQuery.find_or_initialize_by(query: query)
    search_query.content ||= content
    search_query.count ||= 0
    search_query.count += 1
    search_query.save!

    words = content.split.map do |word|
      normalized = word.downcase.strip
      normalized unless AnalyticsService::STOP_WORDS.include?(normalized) || normalized.blank?
    end.compact

    SearchLog.create!(search_query: search_query, words: words, ip: ip)
  end
end
