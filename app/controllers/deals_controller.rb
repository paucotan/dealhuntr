class DealsController < ApplicationController
  # Allow public access to homepage
  skip_before_action :authenticate_user!, only: [:index, :related]
  before_action :set_deal, only: [:show, :related]

  def related
    authorize @deal  # Ensure authorization for related deals
    @related_deals = policy_scope(Deal).where(product_id: @deal.product_id)
                                       .where.not(id: @deal.id)
                                       .where("expiry_date >= ?", Date.today)

    render partial: "related", locals: { related_deals: @related_deals, deal: @deal }, layout: false
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
