
# frozen_string_literal: true
module MallPro
  class Engine < ::Rails::Engine
    engine_name MallPro::PLUGIN_NAME
    isolate_namespace MallPro
    config.after_initialize do
      MallPro.log "Engine loaded"
    end
  end
end

MallPro::Engine.routes.draw do
  namespace :admin do
    get "/" => "home#index"
    resources :products do
      member do
        post :toggle
      end
    end
    resources :coupons do
      member do
        post :void
        post :unvoid
      end
    end
    resources :orders do
      member do
        post :ship
        post :track
      end
    end
  end
end
