class PagesController < ApplicationController
  def home
    @stores = Store.all
    @best_deals = Deal
      .where("expiry_date >= ?", Date.today)
      .order(discounted_price: :desc)
      .limit(10)

    if params[:query].present?
      @search_results = Product.where("name ILIKE ?", "%#{params[:query]}%")
    else
      @search_results = []
    end
  end

  def dashboard
    @user = current_user
  end
end
