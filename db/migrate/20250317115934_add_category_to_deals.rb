class AddCategoryToDeals < ActiveRecord::Migration[7.1]
  def change
    add_column :deals, :category, :string
  end
end
