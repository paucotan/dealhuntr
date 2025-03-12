class Product < ApplicationRecord
  include PgSearch::Model

  has_many :deals
  has_many :favourites

  validates :name, presence: true
  validates :category, presence: true

  pg_search_scope :search_by_name_and_category,
                  against: [:name, :category],
                  using: {
                    tsearch: { prefix: true }
                  }
end
