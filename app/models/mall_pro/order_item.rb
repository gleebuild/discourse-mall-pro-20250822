
# frozen_string_literal: true
module MallPro
  class OrderItem < ::ActiveRecord::Base
    self.table_name = "mall_order_items"
    belongs_to :order, class_name: "MallPro::Order"
    belongs_to :product, class_name: "MallPro::Product"
  end
end
