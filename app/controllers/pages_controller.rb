class PagesController < ApplicationController
  def home
    @stores = Store.all
    if params[:query].present?
      @deals = Product.search_by_name_and_category(params[:query])
    else
      @deals = Deal
                .where("expiry_date >= ?", Date.today)
                .order(discounted_price: :asc)
                .limit(20)
    end
  end

  def search
    if params[:query].present?
      @products = Product.search_by_name_and_category(params[:query])
      @deals = Deal.where(product_id: @products.first.id)
    else
      @products = Product.none
    end
  end

  def dashboard
    @user = current_user
  end
end
