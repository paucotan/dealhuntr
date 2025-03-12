class PagesController < ApplicationController
  def home
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
