class CreateStores < ActiveRecord::Migration[7.1]
  def change
    create_table :stores do |t|
      t.string :name
      t.string :location
      t.string :website_url

      t.timestamps
    end
  end
end
