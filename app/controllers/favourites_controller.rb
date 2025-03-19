class FavouritesController < ApplicationController
  before_action :authenticate_user!

  def create
    @product = Product.find(params[:product_id])
    @favourite = current_user.favourites.find_or_create_by(product: @product)
    authorize @favourite
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path }
    end
  end

  def destroy
    @favourite = current_user.favourites.find(params[:id])
    authorize @favourite
    @product = @favourite.product
    @favourite.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path }
    end
  end


  def index
    @favourites = policy_scope(current_user.favourites.includes(:product))
  end
end
