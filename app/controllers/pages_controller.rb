class PagesController < ApplicationController
  def home
    @stores = Store.all
    @deals = fetch_deals(params[:query])
  end

  def dashboard
    @user = current_user
  end

  private

  def fetch_deals(query)
    if query.present?
      @results = Product.search(params[:query])
      @products = @results.pluck(:id)
      @deals = Deal.where(product_id: @products)
    else
      Deal.where("expiry_date >= ?", Date.today)
          .order(discounted_price: :asc)
          .limit(20)
    end
  end
end
