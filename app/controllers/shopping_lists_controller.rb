class ShoppingListsController < ApplicationController

  def index
    if user_signed_in?
      @shopping_list = current_user.shopping_lists.includes(:deal)
    else
      @shopping_list = session[:shopping_list] || []
    end

    # Calculate total price & savings
    @total_price = @shopping_list.sum { |item| item[:price].to_f }
    @total_savings = @shopping_list.sum { |item| item[:price].to_f - item[:price].to_f }
  end

  def create
    deal = Deal.find(params[:deal_id])
    # raise
    if user_signed_in?
      current_user.shopping_lists.create(deal: deal)
    else
      session[:shopping_list] << {
        deal_id: deal.id,  # Change 'id' to 'deal_id'
        name: deal.product.name,
        store: deal.store.name,
        price: deal.price
      }
    end

    redirect_to shopping_lists_index_path, notice: "Deal added to your shopping list!"
  end

  def destroy
    if user_signed_in?
      item = current_user.shopping_lists.find_by(deal_id: params[:id])
      if item
        item.destroy
      end
    else
      session[:shopping_list]&.delete_if { |item| item[:deal_id].to_i == params[:id].to_i }
    end

    redirect_to shopping_lists_path, notice: "Deal removed from your shopping list."
  end

  def reset
    if user_signed_in?
      current_user.shopping_lists.destroy_all
    else
      session[:shopping_list] = []
    end

    redirect_to shopping_lists_path, notice: "Shopping list cleared."
  end
end
