class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])
    @deals = @product.deals.includes(:store)
  end
end

