class FavouritesController < ApplicationController
  # before_action :authenticate_user! # Ensures only logged-in users can access

  def index
    @favourites = current_user.favourites.includes(:product)
  end

  def create
    @product = Product.find(params[:product_id])
  end

  def destroy
  end
end
