class SearchLog < ApplicationRecord
  belongs_to :search_query

  serialize :words, Array

  validates :ip, presence: true
end
