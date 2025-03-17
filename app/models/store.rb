class Store < ApplicationRecord
  has_many :deals

  validates :name, presence: true
  # validates :location, presence: true
  validates :website_url, presence: true
  # validates :logo_url, presence: true
end
