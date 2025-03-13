class DealsController < ApplicationController
  def related
    @deal = Deal.find(params[:id])
    @related_deals = Deal.where(product_id: @deal.product_id)
                         .where.not(id: @deal.id)
                         .where("expiry_date >= ?", Date.today)

    render partial: "related", locals: { related_deals: @related_deals, deal: @deal }, layout: false
  end

  def show
    @deal = Deal.find(params[:id])
  end
end
