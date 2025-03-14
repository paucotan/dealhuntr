class StoresController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]  # ✅ Allow public access to index and show
  def index
    @stores = policy_scope(Store)
    authorize @stores
  end

  def show
    @store = Store.find(params[:id])
    authorize @store
    @deals = @store.deals.includes(:product)
  end
end
