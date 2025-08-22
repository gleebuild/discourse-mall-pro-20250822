
# frozen_string_literal: true
module MallPro
  module Admin
    class CouponsController < BaseController
      def index
        q = params[:q].to_s.strip
        state = params[:state]
        rel = MallPro::Coupon.order(id: :desc)
        rel = rel.where("code ILIKE ?", "%#{q}%") unless q.blank?
        case state
        when "valid"
          rel = rel.where(voided: false)
        when "voided"
          rel = rel.where(voided: true)
        end
        rows = rel.limit(200).map do |c|
          status = c.voided ? "已作废" : "有效"
          validity = [c.valid_from&.to_date, c.valid_to&.to_date].compact.join(" ~ ")
          %Q(<tr>
            <td>#{c.id}</td>
            <td>#{ERB::Util.html_escape(c.code)}</td>
            <td>#{c.discount_type} #{c.discount_value_cents}分</td>
            <td>#{validity}</td>
            <td>#{status}</td>
            <td>
              <a class="btn" href="/mall/admin/coupons/#{c.id}/edit">修改</a>
              #{c.voided ? '<form method="post" action="/mall/admin/coupons/%d/unvoid" style="display:inline">%s<button class="btn" type="submit">取消作废</button></form>' % [c.id, csrf_tag] : '<form method="post" action="/mall/admin/coupons/%d/void" style="display:inline">%s<button class="btn danger" type="submit">作废</button></form>' % [c.id, csrf_tag]}
            </td>
          </tr>)
        end.join

        body = <<~HTML
          <h2>优惠券码</h2>
          <form method="get" class="row-3">
            <div>
              <label>搜索(券码)</label>
              <input type="text" name="q" value="#{ERB::Util.html_escape(q)}">
            </div>
            <div>
              <label>状态</label>
              <select name="state">
                <option value="">全部</option>
                <option value="valid" #{'selected' if state=='valid'}>有效</option>
                <option value="voided" #{'selected' if state=='voided'}>已作废</option>
              </select>
            </div>
            <div style="align-self:end">
              <button class="btn btn-primary" type="submit">筛选</button>
            </div>
          </form>
          <p><a class="btn btn-primary" href="/mall/admin/coupons/new">+ 创建优惠券码</a></p>
          <table>
            <tr><th>ID</th><th>券码</th><th>优惠</th><th>有效期</th><th>状态</th><th>操作</th></tr>
            #{rows}
          </table>
        HTML
        page("优惠券码列表", body)
      end

      def new
        c = MallPro::Coupon.new(discount_type: :amount, discount_value_cents: 0, voided: false)
        page("创建优惠券码", form_for(c, "/mall/admin/coupons"))
      end

      def create
        c = MallPro::Coupon.new(coupon_params)
        if c.save
          MallPro.log "create coupon id=#{c.id}"
          redirect_to "/mall/admin/coupons"
        else
          page("创建优惠券(有错误)", "<p class='danger'>#{c.errors.full_messages.join('，')}</p>" + form_for(c, "/mall/admin/coupons"))
        end
      end

      def edit
        c = MallPro::Coupon.find(params[:id])
        page("修改优惠券码", form_for(c, "/mall/admin/coupons/#{c.id}", method: "patch"))
      end

      def update
        c = MallPro::Coupon.find(params[:id])
        if c.update(coupon_params)
          MallPro.log "update coupon id=#{c.id}"
          redirect_to "/mall/admin/coupons"
        else
          page("修改优惠券(有错误)", "<p class='danger'>#{c.errors.full_messages.join('，')}</p>" + form_for(c, "/mall/admin/coupons/#{c.id}", method: "patch"))
        end
      end

      def void
        c = MallPro::Coupon.find(params[:id])
        c.update(voided: true)
        MallPro.log "void coupon id=#{c.id}"
        redirect_to "/mall/admin/coupons"
      end

      def unvoid
        c = MallPro::Coupon.find(params[:id])
        c.update(voided: false)
        MallPro.log "unvoid coupon id=#{c.id}"
        redirect_to "/mall/admin/coupons"
      end

      private
      def coupon_params
        params.require(:coupon).permit(:code, :discount_type, :discount_value_cents, :min_amount_cents, :valid_from, :valid_to, :voided)
      end

      def form_for(c, action, method: "post")
        <<~HTML
          <form method="post" action="#{action}">
            #{csrf_tag}
            <input type="hidden" name="_method" value="#{method}"/>
            <div class="row-3">
              <div>
                <label>券码</label>
                <input type="text" name="coupon[code]" value="#{ERB::Util.html_escape(c.code.to_s)}">
              </div>
              <div>
                <label>类型</label>
                <select name="coupon[discount_type]">
                  <option value="amount" #{'selected' if c.discount_type.to_s=='amount'}>立减(分)</option>
                  <option value="percent" #{'selected' if c.discount_type.to_s=='percent'}>折扣(%)</option>
                </select>
              </div>
              <div>
                <label>数值</label>
                <input type="number" name="coupon[discount_value_cents]" value="#{c.discount_value_cents || 0}">
              </div>
              <div>
                <label>最低消费(分)</label>
                <input type="number" name="coupon[min_amount_cents]" value="#{c.min_amount_cents || 0}">
              </div>
              <div>
                <label>起始日期</label>
                <input type="date" name="coupon[valid_from]" value="#{c.valid_from&.to_date}">
              </div>
              <div>
                <label>截止日期</label>
                <input type="date" name="coupon[valid_to]" value="#{c.valid_to&.to_date}">
              </div>
              <div>
                <label>是否作废</label>
                <select name="coupon[voided]">
                  <option value="false" #{'selected' if !c.voided}>否</option>
                  <option value="true" #{'selected' if c.voided}>是</option>
                </select>
              </div>
            </div>
            <p><button class="btn btn-primary" type="submit">保存</button></p>
          </form>
        HTML
      end
    end
  end
end
