class AnalyticsPresenter
  def initialize(logs)
    @logs = logs
  end

  def as_json(_options = {})
    {
      ip: @logs.first&.ip,
      total_logs: @logs.size,
      most_searched_words: most_searched_words,
      most_searched_queries: most_searched_queries,
      queries: grouped_queries
    }
  end

  private

  def grouped_queries
    @logs.group_by(&:search_query).map do |search_query, logs|
      {
        'query' => search_query.query,
        'content' => search_query.content,
        'count' => search_query.count,
        'ip' => logs.first.ip,
        'date' => date_from(search_query.created_at)
      }
    end
  end

  def most_searched_words
    word_counts = @logs.flat_map(&:words).each_with_object(Hash.new(0)) do |word, hash|
      hash[word] += 1
    end

    word_counts.select { |_word, count| count > 1 }
               .sort_by { |_word, count| -count }
               .to_h
  end

  def most_searched_queries
    @logs.map(&:search_query)
         .group_by(&:query)
         .transform_values(&:count)
         .sort_by { |_query, count| -count }
         .to_h
  end

  def date_from(datetime)
    datetime.strftime('%Y-%m-%d %H:%M')
  end
end
