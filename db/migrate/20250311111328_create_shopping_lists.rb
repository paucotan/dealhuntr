class CreateShoppingLists < ActiveRecord::Migration[7.1]
  def change
    create_table :shopping_lists do |t|
      t.references :user, null: false, foreign_key: true
      t.string :deal
      t.references :deal, null: false, foreign_key: true

      t.timestamps
    end
  end
end
