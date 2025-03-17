class Product < ApplicationRecord
  include PgSearch::Model
  # after_commit :set_reindex, on: :create

  # searchkick word_start: [:name, :category]
  has_many :deals
  has_many :favourites

  validates :name, presence: true
  # validates :category, presence: true

  # private

  # def set_reindex
  #   Product.reindex
  # end
  pg_search_scope :search_by_name_and_category,
                  against: [:name, :category],
                  using: {
                    tsearch: { prefix: true } # Allows to find results by partial match
                  }
end
