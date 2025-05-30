class User < ApplicationRecord
  has_many :favourites
  has_many :shopping_lists
  has_many :favourite_products

  # validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
