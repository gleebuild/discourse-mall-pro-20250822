
# frozen_string_literal: true
module MallPro
  module Admin
    class HomeController < BaseController
      def index
        body = <<~HTML
          <h1>Shop Admin</h1>
          <p>如果你能看到此页，说明服务端渲染已生效。</p>
          <ul>
            <li><a href="/mall/admin/products">产品列表</a></li>
            <li><a href="/mall/admin/products/new">创建产品</a></li>
            <li><a href="/mall/admin/coupons">优惠券码</a></li>
            <li><a href="/mall/admin/coupons/new">创建优惠券码</a></li>
            <li><a href="/mall/admin/orders">订单列表</a></li>
          </ul>
        HTML
        page("Shop Admin", body)
      end
    end
  end
end
