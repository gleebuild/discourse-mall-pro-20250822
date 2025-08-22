
# frozen_string_literal: true
class CreateMallCoupons < ActiveRecord::Migration[7.0]
  def change
    create_table :mall_coupons do |t|
      t.string :code, null: false
      t.integer :discount_type, null: false, default: 1 # 0=percent,1=amount
      t.integer :discount_value_cents, null: false, default: 0
      t.integer :min_amount_cents, null: false, default: 0
      t.datetime :valid_from
      t.datetime :valid_to
      t.boolean :voided, null: false, default: false
      t.timestamps
    end
    add_index :mall_coupons, :code, unique: true
  end
end
