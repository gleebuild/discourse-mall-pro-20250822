
# frozen_string_literal: true
# name: discourse-mall-pro-20250822
# about: Mall admin (products/coupons/orders) with Kuaidi100 tracking + SSR pages + logging
# version: 1.0.0
# authors: ChatGPT + GleeBuild
# url: https://lebanx.com/mall/admin
# required_version: 3.0.0

register_asset 'javascripts/discourse/initializers/mall-topnav-20250822.js'

enabled_site_setting :mall_enabled

after_initialize do
  module ::MallPro
    PLUGIN_NAME = "discourse-mall-pro-20250822"
    LOG_PATH = "/var/www/discourse/public/mall.txt"

    def self.log(line)
      begin
        File.open(LOG_PATH, "a") { |f| f.puts("[#{Time.now.utc}] " + line.to_s) }
      rescue => e
        Rails.logger.warn("[MallPro] log error: #{e}")
      end
    end
  end

  require_relative "lib/mall_pro/engine"

  # Make sure engine routes take precedence for SSR under /mall
  Discourse::Application.routes.prepend do
    mount ::MallPro::Engine, at: "/mall"
  end
end
