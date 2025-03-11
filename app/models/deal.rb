class Deal < ApplicationRecord
  belongs_to :product
  belongs_to :store

  validates :price, presence: true
  validates :discounted_price
end
