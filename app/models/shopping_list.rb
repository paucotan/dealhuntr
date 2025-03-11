class ShoppingList < ApplicationRecord
  belongs_to :user
  belongs_to :deal

  validates :user_id, presence: true
  validates :deal_id, presence: true
end
