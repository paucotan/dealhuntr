class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :search]  # ✅ Allow public access to homepage and search

  def home
    @stores = Store.all
    @deals = fetch_deals(params[:query])
  end

  def dashboard
    @user = current_user
    authorize :page, :dashboard? # ✅ Restrict dashboard access with Pundit
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
