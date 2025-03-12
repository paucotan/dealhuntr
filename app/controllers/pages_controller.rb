class PagesController < ApplicationController
  def home
    if params[:query].present?
      @products = Product.search_by_name_and_category(params[:query])
    else
      @products = Product.all
    end
    
    @stores = Store.all
    @best_deals = Deal
      .where("expiry_date >= ?", Date.today)
      .order(discounted_price: :desc)
      .limit(10)
  end

  def dashboard
    @user = current_user
  end
end
