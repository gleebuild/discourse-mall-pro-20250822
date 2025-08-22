
# frozen_string_literal: true
module MallPro
  class Order < ::ActiveRecord::Base
    self.table_name = "mall_orders"
    belongs_to :user, class_name: "::User", optional: true
    has_many :items, class_name: "MallPro::OrderItem", foreign_key: :order_id
    serialize :tracking_events, JSON
  end
end
