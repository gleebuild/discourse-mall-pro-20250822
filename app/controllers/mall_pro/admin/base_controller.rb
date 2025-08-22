
# frozen_string_literal: true
module MallPro
  module Admin
    class BaseController < ::ApplicationController
      before_action :ensure_logged_in
      before_action :ensure_admin

      private
      def page(title, body_html)
        MallPro.log "render: #{title} by user=#{current_user&.username}"
        html = <<~HTML
        <!DOCTYPE html>
        <html lang="zh-CN">
        <head>
          <meta charset="utf-8" />
          <title>#{title}</title>
          <meta name="viewport" content="width=device-width, initial-scale=1" />
          <style>
            body{{font-family:-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Helvetica,Arial,sans-serif;padding:18px;line-height:1.55}}
            a{{color:#0e7; text-decoration:none}}
            input, select, textarea{{padding:8px;border:1px solid #ddd;border-radius:8px;width:100%;box-sizing:border-box}}
            label{{display:block;margin:8px 0 4px;color:#333}}
            table{{border-collapse:collapse;width:100%;}}
            th,td{{border:1px solid #e5e7eb;padding:8px;text-align:left;font-size:14px}}
            th{{background:#f9fafb}}
            .row{{display:grid;grid-template-columns:repeat(2,1fr);gap:12px}}
            .row-3{{display:grid;grid-template-columns:repeat(3,1fr);gap:12px}}
            .btn{{display:inline-block;padding:8px 12px;border:1px solid #ddd;border-radius:8px;background:#fff;cursor:pointer}}
            .btn-primary{{background:#10b981;color:white;border-color:#10b981}}
            .muted{{color:#6b7280}}
            .topnav a{{margin-right:12px}}
            .danger{{color:#ef4444}}
          </style>
        </head>
        <body>
          <div class="topnav">
            <a href="/mall/admin">返回管理</a>
            <a href="/mall/admin/products">产品列表</a>
            <a href="/mall/admin/products/new">创建产品</a>
            <a href="/mall/admin/coupons">优惠券码</a>
            <a href="/mall/admin/coupons/new">创建优惠券码</a>
            <a href="/mall/admin/orders">订单列表</a>
          </div>
          <hr/>
          #{body_html}
        </body>
        </html>
        HTML
        render html: html.html_safe
      end

      def csrf_tag
        %Q(<input type="hidden" name="authenticity_token" value="#{form_authenticity_token}">).html_safe
      end
    end
  end
end
