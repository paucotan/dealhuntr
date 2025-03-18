class DealsController < ApplicationController
  # Allow public access to homepage
  skip_before_action :authenticate_user!, only: [:index, :related]
  before_action :set_deal, only: [:show, :related]

  def related
    authorize @deal  # Ensure authorization for related deals
    @related_deals = policy_scope(Deal).where(product_id: @deal.product_id)
                                       .where.not(id: @deal.id)
                                       .where("expiry_date >= ?", Date.today)



    keywords = @deal.product.name.downcase.scan(/\w+/)
    ignored_words = ["ah", "alle", "de", "het", "van", "en", "of", "met", "gram", "300", "250", "500", "AH"]
    keywords -= ignored_words
    keywords = [@deal.product.name.split(" ").last.downcase] if keywords.empty?
    conditions = keywords.map { |word| "products.name ILIKE ?" }.join(" OR ")
    values = keywords.map { |word| "%#{word}%" }

    @similar_deals = policy_scope(Deal)
                      .joins(:product)
                      .where(conditions, *values)
                      .where.not(id: @deal.id)
                      .limit(5)

    render partial: "related", locals: { related_deals: @related_deals, similar_deals: @similar_deals, deal: @deal }, layout: false

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
