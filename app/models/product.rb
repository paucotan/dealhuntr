class Product < ApplicationRecord
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
end
