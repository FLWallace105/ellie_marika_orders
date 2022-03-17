require 'dotenv'

require 'active_record'
require 'sinatra/activerecord/rake'

require_relative 'ellie_orders'

Dotenv.load
include ActiveRecord::Tasks

namespace :shopify_orders do

    desc 'test product collection get products'
    task :test_product_collection do |t|
        ShopifyOrders::GetOrderInfo.new.test_product_collection
    end

    desc 'run Jennifer Johnson request body_html requested product'
    task :jen_request_products do |t|
        ShopifyOrders::GetOrderInfo.new.jennifer_products

    end
    
    desc "List Ellie Orders my_min='2018-04-14T00:00:00-04:00' my_max='2018-04-16T23:58:00-4:00'"
    task :list_ellie_orders, :my_min, :my_max do |t, args|
        my_min = args['my_min']
        my_max = args['my_max']
        ShopifyOrders::GetOrderInfo.new.get_orders(my_min, my_max)
    end 

    #get_special_ellie_orders
    desc "Get special Ellie Orders to determine if skus are missing, my_min='2018-04-14T00:00:00-04:00' my_max='2018-04-16T23:58:00-4:00'"
    task :get_ellie_orders_special, :my_min, :my_max do |t, args|
        my_min = args['my_min']
        my_max = args['my_max']
        ShopifyOrders::GetOrderInfo.new.get_special_ellie_orders(my_min, my_max)

    end


    #get_marika_orders
    desc "List MARIKA Orders my_min='2018-04-14T00:00:00-04:00' my_max='2018-04-16T23:58:00-4:00'"
    task :list_marika_orders, :my_min, :my_max do |t, args|
        my_min = args['my_min']
        my_max = args['my_max']
        ShopifyOrders::GetOrderInfo.new.get_marika_orders(my_min, my_max)
    end 

    #get_ellie_collect
    desc "Get the List of Ellie Collects"
    task :get_ellie_collects do |t|
        ShopifyOrders::GetOrderInfo.new.get_ellie_collect

    end

    #get_ellie_collections
    desc "Get the list of Ellie COLLECTIONS"
    task :get_ellie_collections do |t|
        ShopifyOrders::GetOrderInfo.new.get_ellie_collections
    end

    #get_ellie_products
    desc "Get all the products from ELLIE"
    task :get_ellie_products do |t|
        ShopifyOrders::GetOrderInfo.new.get_ellie_products
    end

    #get_yesterday
    desc "Get yesterday's date"
    task :get_yesterday do |t|
        ShopifyOrders::GetOrderInfo.new.get_yesterday
    end

    #get marika products and variants
    desc "Get Marika Products and Variants"
    task :get_marika_products do |t|
        ShopifyOrders::GetOrderInfo.new.get_marika_products
    end

    desc "Get Zobha Products and Variants"
    task :get_zobha_products do |t|
        ShopifyOrders::GetOrderInfo.new.get_zobha_products
    end

    #find_marika_duplicate_skus
    desc "Find Marika Duplicate Skus"
    task :find_marika_duplicate_skus do |t|
        ShopifyOrders::GetOrderInfo.new.find_marika_duplicate_skus
    end


    desc "Find Ellie Duplicate Skus"
    task :find_ellie_duplicate_skus do |t|
        ShopifyOrders::GetOrderInfo.new.find_ellie_duplicate_skus
    end

    desc "Emergency create order"
    task :emergency_create_order do |t|
        ShopifyOrders::GetOrderInfo.new.emergency_post_order

    end

end