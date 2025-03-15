class MakePriceNullableInDeals < ActiveRecord::Migration[7.1]
  def change
    change_column_null :deals, :price, true
  end
end
