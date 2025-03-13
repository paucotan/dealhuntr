class PagesController < ApplicationController
  def home
    @stores = Store.all
    @deals = fetch_deals(params[:query])
  end

  def search
    @deals = fetch_deals(params[:query])

    respond_to do |format|
      format.html { render "home" }
      format.js { render partial: "search_results", locals: { deals: @deals } }
    end
  end

  def dashboard
    @user = current_user
  end

  private

  def fetch_deals(query)
    if query.present?
      Deal.includes(:product, :store)
          .joins(:product)
          .where("products.name ILIKE ? OR products.category ILIKE ?", "%#{query}%", "%#{query}%")
    else
      Deal.where("expiry_date >= ?", Date.today)
          .order(discounted_price: :asc)
          .limit(20)
    end
  end
end
