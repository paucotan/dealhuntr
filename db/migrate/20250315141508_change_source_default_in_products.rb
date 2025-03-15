class ChangeSourceDefaultInProducts < ActiveRecord::Migration[7.1]
  def change
    # Change the default value for new records
    change_column_default :products, :source, 'seed'

    # Backfill existing NULL values with 'seed'
    Product.where(source: nil).update_all(source: 'seed')
  end
end
