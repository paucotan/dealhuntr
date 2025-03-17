class AddDealTypeToDeals < ActiveRecord::Migration[7.1]
  def change
    add_column :deals, :deal_type, :string
  end
end
