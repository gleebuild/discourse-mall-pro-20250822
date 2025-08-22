
# frozen_string_literal: true
class CreateMallOrderItems < ActiveRecord::Migration[7.0]
  def change
    create_table :mall_order_items do |t|
      t.integer :order_id, null: false
      t.integer :product_id, null: false
      t.integer :quantity, null: false, default: 1
      t.integer :price_cents, null: false, default: 0
      t.timestamps
    end
    add_index :mall_order_items, :order_id
  end
end
