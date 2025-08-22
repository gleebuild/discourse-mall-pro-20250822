
# discourse-mall-pro-20250822

- 管理入口：`/mall/admin`
- 仅管理员可访问。
- 功能：创建/筛选/修改/上下架产品；创建/筛选/修改/作废优惠券；筛选/修改订单、录入快递公司与运单号；一键从快递100抓取轨迹并保存。
- 日志：所有操作写入 `/var/www/discourse/public/mall.txt`。

## 安装
1. 将本仓库放入 `/var/www/discourse/plugins/discourse-mall-pro-20250822`。
2. 重新构建容器：`cd /var/discourse && ./launcher rebuild app`。
3. 后台 -> 设置 搜索 `mall_enabled` 确保开启。

## 数据表
执行插件迁移后会创建：
- mall_products
- mall_coupons
- mall_orders
- mall_order_items

## 备注
- 快递100：优先走公开接口 `https://www.kuaidi100.com/query`。如需更稳，可在站点设置中配置 `mall_kd100_customer` 与 `mall_kd100_key`，自行扩展到官方 poll API（控制器里留有占位）。
