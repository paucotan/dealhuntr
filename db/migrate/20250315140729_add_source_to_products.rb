class AddSourceToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :source, :string, default: 'seed'
  end
end
