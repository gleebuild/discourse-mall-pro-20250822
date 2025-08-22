
# frozen_string_literal: true
class CreateMallOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :mall_orders do |t|
      t.string :number, null: false
      t.integer :user_id
      t.string :status, null: false, default: "pending"
      t.integer :total_cents, null: false, default: 0
      t.string :shipping_company
      t.string :tracking_no
      t.jsonb :tracking_events, default: []
      t.timestamps
    end
    add_index :mall_orders, :number, unique: true
    add_index :mall_orders, :user_id
  end
end
