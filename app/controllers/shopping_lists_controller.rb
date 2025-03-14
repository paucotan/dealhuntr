class ShoppingListsController < ApplicationController
  include Pundit

  before_action :authenticate_user!
  before_action :authorize_shopping_list

  def index
    @shopping_list = policy_scope(ShoppingList) # ✅ Correct Pundit scoping
    @total_price = @shopping_list.sum { |item| item[:price].to_f }
    @total_savings = @shopping_list.sum { |item| item[:price].to_f - item[:price].to_f }
  end

  def create
    deal = Deal.find(params[:deal_id])
    shopping_list = current_user.shopping_lists.create(deal: deal)
    authorize shopping_list

    flash[:alert] = "Deal added to your shopping list!"
    redirect_to shopping_lists_path
  end

  def destroy
    item = current_user.shopping_lists.find_by(deal_id: params[:id])
    authorize item
    item&.destroy

    flash[:alert] = "Deal removed from your shopping list."
    redirect_to shopping_lists_path
  end

  def reset
    authorize current_user.shopping_lists
    current_user.shopping_lists.destroy_all

    flash[:alert] = "Shopping list cleared."
    redirect_to shopping_lists_path
  end

  private

  def authorize_shopping_list
    authorize ShoppingList
  end
end
