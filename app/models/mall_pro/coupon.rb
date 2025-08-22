
# frozen_string_literal: true
module MallPro
  class Coupon < ::ActiveRecord::Base
    self.table_name = "mall_coupons"
    validates :code, presence: true, uniqueness: true
    enum discount_type: {{ percent: 0, amount: 1 }}
  end
end
