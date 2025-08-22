
# frozen_string_literal: true
module MallPro
  module Admin
    class ProductsController < BaseController
      def index
        q = params[:q].to_s.strip
        status = params[:status]
        rel = MallPro::Product.all.order(id: :desc)
        rel = rel.where("name ILIKE ? OR sku ILIKE ?", "%#{q}%", "%#{q}%") unless q.blank?
        rel = rel.where(active: status == "on") if status.present? && status != "all"
        rows = rel.limit(200).map do |p|
          %Q(<tr>
              <td>#{p.id}</td>
              <td>#{ERB::Util.html_escape(p.name)}</td>
              <td>#{ERB::Util.html_escape(p.sku)}</td>
              <td>¥#{sprintf("%.2f", p.price_cents.to_i/100.0)}</td>
              <td>#{p.stock}</td>
              <td>#{p.active ? "上架" : "下架"}</td>
              <td>
                <a class="btn" href="/mall/admin/products/#{p.id}/edit">修改</a>
                <form method="post" action="/mall/admin/products/#{p.id}/toggle" style="display:inline">
                  #{csrf_tag}
                  <button class="btn" type="submit">#{p.active ? "下架" : "上架"}</button>
                </form>
              </td>
            </tr>)
        end.join

        body = <<~HTML
          <h2>产品列表</h2>
          <form method="get" class="row">
            <div>
              <label>搜索(名称/SKU)</label>
              <input type="text" name="q" value="#{ERB::Util.html_escape(q)}">
            </div>
            <div>
              <label>状态</label>
              <select name="status">
                <option value="all" #{'selected' if status=='all'}>全部</option>
                <option value="on" #{'selected' if status=='on'}>上架</option>
                <option value="off" #{'selected' if status=='off'}>下架</option>
              </select>
            </div>
            <div style="align-self:end">
              <button class="btn btn-primary" type="submit">筛选</button>
            </div>
          </form>
          <p><a class="btn btn-primary" href="/mall/admin/products/new">+ 创建产品</a></p>
          <table>
            <tr><th>ID</th><th>名称</th><th>SKU</th><th>价格</th><th>库存</th><th>状态</th><th>操作</th></tr>
            #{rows}
          </table>
        HTML
        page("产品列表", body)
      end

      def new
        p = MallPro::Product.new
        page("创建产品", form_for(p, "/mall/admin/products"))
      end

      def create
        p = MallPro::Product.new(product_params)
        if p.save
          MallPro.log "create product id=#{p.id}"
          redirect_to "/mall/admin/products"
        else
          page("创建产品(有错误)", "<p class='danger'>#{p.errors.full_messages.join('，')}</p>" + form_for(p, "/mall/admin/products"))
        end
      end

      def edit
        p = MallPro::Product.find(params[:id])
        page("修改产品", form_for(p, "/mall/admin/products/#{p.id}", method: "patch"))
      end

      def update
        p = MallPro::Product.find(params[:id])
        if p.update(product_params)
          MallPro.log "update product id=#{p.id}"
          redirect_to "/mall/admin/products"
        else
          page("修改产品(有错误)", "<p class='danger'>#{p.errors.full_messages.join('，')}</p>" + form_for(p, "/mall/admin/products/#{p.id}", method: "patch"))
        end
      end

      def toggle
        p = MallPro::Product.find(params[:id])
        p.update(active: !p.active)
        MallPro.log "toggle product id=#{p.id} active=#{p.active}"
        redirect_to "/mall/admin/products"
      end

      private
      def product_params
        params.require(:product).permit(:name, :sku, :price_cents, :stock, :active, :image_url, :description)
      end

      def form_for(p, action, method: "post")
        <<~HTML
          <form method="post" action="#{action}">
            #{csrf_tag}
            <input type="hidden" name="_method" value="#{method}"/>
            <div class="row">
              <div>
                <label>名称</label>
                <input type="text" name="product[name]" value="#{ERB::Util.html_escape(p.name.to_s)}">
              </div>
              <div>
                <label>SKU</label>
                <input type="text" name="product[sku]" value="#{ERB::Util.html_escape(p.sku.to_s)}">
              </div>
              <div>
                <label>价格(分)</label>
                <input type="number" name="product[price_cents]" value="#{p.price_cents || 0}">
              </div>
              <div>
                <label>库存</label>
                <input type="number" name="product[stock]" value="#{p.stock || 0}">
              </div>
              <div>
                <label>图片URL</label>
                <input type="text" name="product[image_url]" value="#{ERB::Util.html_escape(p.image_url.to_s)}">
              </div>
              <div>
                <label>是否上架</label>
                <select name="product[active]">
                  <option value="true" #{'selected' if p.active}>上架</option>
                  <option value="false" #{'selected' if !p.active}>下架</option>
                </select>
              </div>
            </div>
            <div>
              <label>描述</label>
              <textarea name="product[description]" rows="5">#{ERB::Util.html_escape(p.description.to_s)}</textarea>
            </div>
            <p><button class="btn btn-primary" type="submit">保存</button></p>
          </form>
        HTML
      end
    end
  end
end
