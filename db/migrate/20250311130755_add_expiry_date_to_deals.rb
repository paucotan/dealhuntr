class AddExpiryDateToDeals < ActiveRecord::Migration[7.1]
  def change
    add_column :deals, :expiry_date, :date
  end
end
