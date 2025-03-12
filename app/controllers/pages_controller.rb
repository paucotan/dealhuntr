class PagesController < ApplicationController
  def home
    if params[:query].present?
      @products = Product.search_by_name_and_category(params[:query])
    else
      @products = Product.all
    end
    
    @stores = Store.all

    @deals = Deal
      .where("expiry_date >= ?", Date.today)
      .order(discounted_price: :asc)
      .limit(20)

    @search_results = if params[:query].present?
      Product.where("name ILIKE ?", "%#{params[:query]}%")
    else
      nil
    end
  end

  def dashboard
    @user = current_user
  end
end
