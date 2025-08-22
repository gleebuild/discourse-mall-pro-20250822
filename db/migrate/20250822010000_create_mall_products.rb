
# frozen_string_literal: true
class CreateMallProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :mall_products do |t|
      t.string :name, null: false
      t.string :sku, null: false
      t.integer :price_cents, null: false, default: 0
      t.integer :stock, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.string :image_url
      t.text :description
      t.timestamps
    end
    add_index :mall_products, :sku, unique: true
  end
end
