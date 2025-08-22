
# frozen_string_literal: true
require "net/http"
require "json"
require "cgi"
module MallPro
  module Admin
    class OrdersController < BaseController
      def index
        q = params[:q].to_s.strip
        state = params[:state]
        rel = MallPro::Order.order(id: :desc)
        rel = rel.where("number ILIKE ?", "%#{q}%") unless q.blank?
        rel = rel.where(status: state) unless state.blank?
        rows = rel.limit(200).map do |o|
          %Q(<tr>
            <td>#{o.id}</td>
            <td>#{ERB::Util.html_escape(o.number)}</td>
            <td>#{o.status}</td>
            <td>¥#{sprintf("%.2f", o.total_cents.to_i/100.0)}</td>
            <td>#{o.user_id}</td>
            <td>#{ERB::Util.html_escape(o.shipping_company.to_s)}</td>
            <td>#{ERB::Util.html_escape(o.tracking_no.to_s)}</td>
            <td>
              <a class="btn" href="/mall/admin/orders/#{o.id}/edit">修改</a>
            </td>
          </tr>)
        end.join

        body = <<~HTML
          <h2>订单列表</h2>
          <form method="get" class="row-3">
            <div>
              <label>搜索(订单号)</label>
              <input type="text" name="q" value="#{ERB::Util.html_escape(q)}">
            </div>
            <div>
              <label>状态</label>
              <select name="state">
                <option value="">全部</option>
                #{%w[pending paid shipped completed cancelled refunded].map{|s| %Q(<option value="#{s}" #{'selected' if state==s}>#{s}</option>)}.join}
              </select>
            </div>
            <div style="align-self:end">
              <button class="btn btn-primary" type="submit">筛选</button>
            </div>
          </form>
          <table>
            <tr><th>ID</th><th>订单号</th><th>状态</th><th>金额</th><th>用户ID</th><th>快递公司</th><th>运单号</th><th>操作</th></tr>
            #{rows}
          </table>
        HTML
        page("订单列表", body)
      end

      def edit
        o = MallPro::Order.find(params[:id])
        items_rows = o.items.map do |it|
          p = it.product
          %Q(<tr><td>#{p&.name}</td><td>#{it.quantity}</td><td>¥#{sprintf("%.2f", it.price_cents.to_i/100.0)}</td></tr>)
        end.join
        events_html = (o.tracking_events || []).map { |e| "<li>#{ERB::Util.html_escape(e[\"time\"].to_s)} — #{ERB::Util.html_escape(e[\"context\"].to_s)}</li>" }.join
        body = <<~HTML
          <h2>修改订单</h2>
          <p class="muted">订单号：#{ERB::Util.html_escape(o.number)}</p>
          <table>
            <tr><th>商品</th><th>数量</th><th>单价</th></tr>
            #{items_rows}
          </table>
          <form method="post" action="/mall/admin/orders/#{o.id}">
            #{csrf_tag}
            <input type="hidden" name="_method" value="patch"/>
            <div class="row-3">
              <div>
                <label>状态</label>
                <select name="order[status]">
                  #{%w[pending paid shipped completed cancelled refunded].map{|s| %Q(<option value="#{s}" #{'selected' if o.status==s}>#{s}</option>)}.join}
                </select>
              </div>
              <div>
                <label>快递公司(拼音代码，如: yunda, shunfeng, zhongtong)</label>
                <input type="text" name="order[shipping_company]" value="#{ERB::Util.html_escape(o.shipping_company.to_s)}">
              </div>
              <div>
                <label>运单号</label>
                <input type="text" name="order[tracking_no]" value="#{ERB::Util.html_escape(o.tracking_no.to_s)}">
              </div>
            </div>
            <p><button class="btn btn-primary" type="submit">保存</button></p>
          </form>
          <form method="post" action="/mall/admin/orders/#{o.id}/track">
            #{csrf_tag}
            <button class="btn" type="submit">从快递100查询轨迹并保存</button>
          </form>
          <h3>已保存的轨迹</h3>
          <ol>#{events_html}</ol>
        HTML
        page("订单详情", body)
      end

      def update
        o = MallPro::Order.find(params[:id])
        if o.update(order_params)
          MallPro.log "update order id=#{o.id}"
          redirect_to "/mall/admin/orders"
        else
          page("修改订单(有错误)", "<p class='danger'>#{o.errors.full_messages.join('，')}</p>")
        end
      end

      # Track using Kuaidi100 public endpoint (no key). If customer/key are set, use official poll API.
      def track
        o = MallPro::Order.find(params[:id])
        company = o.shipping_company.to_s.strip
        num = o.tracking_no.to_s.strip
        if company.blank? || num.blank?
          return page("查询失败", "<p class='danger'>请先填写快递公司和运单号。</p>")
        end
        events = []
        begin
          # Prefer public JSON endpoint
          uri = URI("https://www.kuaidi100.com/query?type=#{CGI.escape(company)}&postid=#{CGI.escape(num)}&temp=#{rand()}")
          MallPro.log "kd100 GET #{uri}"
          res = Net::HTTP.get_response(uri)
          if res.is_a?(Net::HTTPSuccess)
            data = JSON.parse(res.body) rescue {}
            if data["status"] == "200"
              events = (data["data"] || []).map {{ |row| {{ "time" => row["time"] || row["ftime"], "context" => row["context"] || row["status"] }} }}
            else
              MallPro.log "kd100 resp status=#{data["status"]} msg=#{data["message"]}"
            end
          else
            MallPro.log "kd100 http #{res.code}"
          end
        rescue => e
          MallPro.log "kd100 error: #{e}"
        end
        if events.any?
          o.update(tracking_events: events)
          msg = "<p>轨迹已更新，共#{events.size}条。</p>"
        else
          msg = "<p class='danger'>未拿到轨迹，可能需要设置 mall_kd100_customer/mall_kd100_key 使用官方接口。</p>"
        end
        body = msg + %Q(<p><a class="btn" href="/mall/admin/orders/#{o.id}/edit">返回订单</a></p>)
        page("快递100查询结果", body)
      end

      private
      def order_params
        params.require(:order).permit(:status, :shipping_company, :tracking_no)
      end
    end
  end
end
