class MakeLocationAndLogoUrlNullableInStores < ActiveRecord::Migration[7.1]
  def change
    # Make location and logo_url nullable
    change_column_null :stores, :location, true
    change_column_null :stores, :logo_url, true
  end
end
