class FindRecordsJob < ApplicationJob
  queue_as :default

  def perform(query, ip)
    puts "[FindRecordsJob] Starting with query: #{query}, ip: #{ip}"
    content = transform_query(query)
    search_query = find_or_create_query(query, content)
    words = extract_words(content)
    create_search_log(search_query, words, ip)
  rescue StandardError => e
    Rails.logger.error("[FindRecordsJob] Error: #{e.message}")
    puts "[FindRecordsJob] Exception: #{e.message}"
  end

  private

  def transform_query(query)
    content = query.gsub('+', ' ')
    puts "[FindRecordsJob] Transformed content: #{content}"
    content
  end

  def find_or_create_query(query, content)
    search_query = SearchQuery.find_or_initialize_by(query: query)
    search_query.content ||= content
    search_query.count ||= 0
    search_query.count += 1

    if search_query.save
      puts "[FindRecordsJob] Saved search_query: #{search_query.id}, count: #{search_query.count}"
    else
      puts "[FindRecordsJob] Failed to save search_query: #{search_query.errors.full_messages.join(', ')}"
    end

    search_query
  end

  def extract_words(content)
    content.split.map do |word|
      normalized = word.downcase.strip
      normalized unless AnalyticsService::STOP_WORDS.include?(normalized) || normalized.blank?
    end.compact
  end

  def create_search_log(search_query, words, ip)
    log = SearchLog.create(search_query: search_query, words: words, ip: ip)
    puts "[FindRecordsJob] Created search log: #{log.id}, words: #{words.join(', ')}"
  end
end
