class AnalyticsPresenter
  def initialize(search_queries)
    @search_queries = search_queries
  end

  def as_json(_options = {})
    @search_queries.map do |sq|
      {
        'content' => sq.content,
        'count' => sq.count,
        'words' => aggregated_words(sq),
        'ips' => aggregated_ips(sq)
      }
    end
  end

  private

  def aggregated_words(search_query)
    all_words = search_query.search_logs.pluck(:words).flatten
    all_words.each_with_object(Hash.new(0)) do |word, counts|
      counts[word] += 1
    end
  end

  def aggregated_ips(search_query)
    search_query.search_logs.pluck(:ip).uniq
  end
end
