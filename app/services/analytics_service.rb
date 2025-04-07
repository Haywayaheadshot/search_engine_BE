class AnalyticsService
  STOP_WORDS = %w[
    a an the and or but is to in of for on at by with from as if then
    how why what when
  ].freeze

  def self.record_search(query, ip)
    if query.blank?
      Rails.logger.error('Empty query provided')
      return
    end

    if use_redis?
      record_in_redis(query, ip)
    else
      FindRecordsJob.perform_later(query, ip)
    end
  end

  def self.use_redis?
    ENV['USE_REDIS_FOR_ANALYTICS'] == 'true'
  end

  def self.record_in_redis(query, ip)
    redis = Redis.new
    redis.incr("analytics:search_query:#{query}:count")
    redis.set("analytics:search_log:#{query}:ip", ip)

    transformed_query = query.gsub('+', ' ')

    redis.set("analytics:search_query:#{query}:content", transformed_query)

    words = transformed_query.split.map { |w| w.downcase.strip }
      .reject { |w| w.blank? || STOP_WORDS.include?(w) }
    redis.set("analytics:search_log:#{query}:words", words.to_json)
  end
end
