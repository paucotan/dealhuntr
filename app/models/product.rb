class Product < ApplicationRecord
  has_many :deals
  has_many :favourites

  validates :name, presence: true
  validates :category, presence: true
end
