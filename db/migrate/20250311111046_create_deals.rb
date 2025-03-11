class CreateDeals < ActiveRecord::Migration[7.1]
  def change
    create_table :deals do |t|
      t.float :price
      t.float :discounted_price
      t.references :product, null: false, foreign_key: true
      t.references :store, null: false, foreign_key: true

      t.timestamps
    end
  end
end
