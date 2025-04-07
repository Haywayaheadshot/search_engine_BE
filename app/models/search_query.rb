class SearchQuery < ApplicationRecord
  has_many :search_logs, dependent: :destroy

  validates :query, presence: true, uniqueness: true
  validates :count, numericality: { greater_than_or_equal_to: 0 }
end
