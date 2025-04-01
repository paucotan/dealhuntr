class FavouritesController < ApplicationController
  before_action :authenticate_user!

  def create
    @product = Product.find(params[:product_id])
    @favourite = current_user.favourites.find_or_create_by(product: @product)
    authorize @favourite
    # Find the deal associated with this product (you may need to adjust this logic)
    @deal = Deal.find_by(product_id: @product.id) # Adjust based on your associations
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path }
    end
  end

  def destroy
    @favourite = current_user.favourites.find_by(id: params[:id])
    authorize @favourite if @favourite
    if @favourite
      @product = @favourite.product
      @deal = Deal.find_by(product_id: @product.id) # Adjust based on your associations
      @favourite.destroy
    else
      Rails.logger.warn("Favourite with id=#{params[:id]} not found for user=#{current_user.id}")
    end
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path }
    end
  end

  def index
    @favourites = policy_scope(current_user.favourites.includes(:product))
  end
end
