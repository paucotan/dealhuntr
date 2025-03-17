class Deal < ApplicationRecord
  belongs_to :product
  belongs_to :store

  # validates :price, presence: true
  validates :expiry_date, presence: true
  validates :discounted_price, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
end
