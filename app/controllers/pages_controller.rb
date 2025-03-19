class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :search]  # ✅ Allow public access to homepage and search
  DEEPL_AUTH_KEY = ENV["DEEPL_AUTH_KEY"]
  HOST = ENV["DEEPL_HOST"]

  def home
    authorize :page, :home?
    @stores = Store.all
    @deals = fetch_deals(params[:query])

    # Apply store filter if store_id is present
    if params[:store_id].present?
      @deals = @deals.where(store_id: params[:store_id])
    end

    # Apply category filter if category is present
    if params[:category].present?
      if params[:category] == "Uncategorized"
        @deals = @deals.joins(:product).where(products: { category: [nil, "Uncategorized"] })
      else
        @deals = @deals.joins(:product).where(products: { category: params[:category] })
      end
    end

    # Add pagination to the deals query
    @pagy, @deals = pagy(@deals)
    # Get unique categories for the filter bar from products linked to deals
    @categories = Product.joins(:deals).distinct.pluck(:category).compact.reject { |c| c == "Uncategorized" }.uniq.sort
  end

  def dashboard
    @user = current_user
    authorize :page, :dashboard? # ✅ Restrict dashboard access with Pundit
  end

  private

  def fetch_deals(query)
    base_query = Deal.joins(:product)
                     .where("expiry_date >= ?", Date.today)
                     .where.not(products: { name: "No name" }) # Filter out "No name" products
                     .where.not(products: { category: [nil, "Uncategorized"] }) # Filter out Uncategorized products

    if query.present?
      translated_query = DeepL.translate(query, 'EN', 'NL', auth_key: DEEPL_AUTH_KEY, host: HOST).text
      product_ids = Product.search_by_name_and_category(translated_query).pluck(:id)
      base_query.where(product_id: product_ids)
                .order(discounted_price: :asc)
    else
      base_query.order(discounted_price: :asc)
    end
  end
end
