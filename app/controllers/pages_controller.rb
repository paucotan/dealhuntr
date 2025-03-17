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
        @deals = @deals.where(category: [nil, "Uncategorized"])
      else
        @deals = @deals.where(category: params[:category])
      end
    end

    # Add pagination to the deals query
    # Get unique categories for the filter bar
    @categories = Deal.distinct.pluck(:category).map { |c| c || "Uncategorized" }.uniq.sort
    @pagy, @deals = pagy(@deals)
  end

  def dashboard
    @user = current_user
    authorize :page, :dashboard? # ✅ Restrict dashboard access with Pundit
  end

  private

  def fetch_deals(query)
#     deals = Deal.where("expiry_date >= ?", Date.today)
#                 .order(discounted_price: :asc)

#     if query.present?
#       @results = Product.search(params[:query])
#       @products = @results.pluck(:id)
#       deals = deals.where(product_id: @products)

    # if query.present?
    #   @results = Product.search(params[:query])
    #   @products = @results.pluck(:id)
    #   @deals = Deal.where(product_id: @products)
    # else
    #   Deal.where("expiry_date >= ?", Date.today)
    #       .order(discounted_price: :asc)
    #      # .limit(20)
    # end

    if query.present?
      translated_query = DeepL.translate(query, 'EN', 'NL', auth_key: DEEPL_AUTH_KEY,
      host: HOST ).text
      product_ids = Product.search_by_name_and_category(translated_query).pluck(:id)
      Deal.where(product_id: product_ids)
          .where("expiry_date >= ?", Date.today)
          .order(discounted_price: :asc)
    else
      Deal.where("expiry_date >= ?", Date.today)
          .order(discounted_price: :asc)
    end
    deals
  end
end
