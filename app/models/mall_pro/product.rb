
# frozen_string_literal: true
module MallPro
  class Product < ::ActiveRecord::Base
    self.table_name = "mall_products"
    validates :name, presence: true
    validates :sku, presence: true, uniqueness: true
    scope :active, -> { where(active: true) }
  end
end
