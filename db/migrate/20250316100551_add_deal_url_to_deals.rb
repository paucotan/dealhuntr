class AddDealUrlToDeals < ActiveRecord::Migration[7.1]
  def change
    add_column :deals, :deal_url, :string
  end
end
