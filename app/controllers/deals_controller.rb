class DealsController < ApplicationController
  # Allow public access to homepage
  skip_before_action :authenticate_user!, only: [:index, :related]
  before_action :set_deal, only: [:show, :related]

  def related
    authorize @deal  # Ensure authorization for related deals
    @related_deals = policy_scope(Deal).where(product_id: @deal.product_id)
                                       .where.not(id: @deal.id)

    keywords = @deal.product.name.downcase.scan(/\w+/)
    ignored_words = ["ah", "jumbo", "vomar", "lidl", "alle", "de", "het", "van", "en", "of", "met", "gram", "300", "250", "500", "in", "350",
                    "330", "ml", "s", "100"]
    keywords -= ignored_words
    keywords = [@deal.product.name.split(" ").last.downcase] if keywords.empty?
    # Rails.logger.info("Keywords: #{keywords}")

    # Build conditions for similar deals based on category and name
    conditions = keywords.map { |_word| "products.name ILIKE ?" }.join(" OR ")
    values = keywords.map { |word| "%#{word}%" }

    @similar_deals = policy_scope(Deal)
                    .joins(:product)
                    .where(conditions, *values)
                    .where(category: @deal.category)
                    .where.not(id: @deal.id)
                    .limit(2)

    @not_so_similar_deals = policy_scope(Deal)
                            .joins(:product)
                            .where(category: @deal.category)
                            .limit(2)

    if @similar_deals.first
      render partial: "related", locals: { related_deals: @similar_deals, deal: @deal }, layout: false
    else
      render partial: "related", locals: { related_deals: @not_so_similar_deals, deal: @deal }, layout: false
    end
  end

  def show
    authorize @deal  # Ensure only authorized users can view deals
  end

  private

  def set_deal
    @deal = Deal.find_by(id: params[:id])
    return redirect_to deals_path, alert: "Deal not found." unless @deal
  end
end
