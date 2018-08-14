#ellie_orders.rb
require 'shopify_api'
require 'dotenv'
require 'csv'
#Dotenv.load
require 'active_record'
require "sinatra/activerecord"
require_relative 'models/model'


module ShopifyOrders
    class GetOrderInfo

        def initialize
            Dotenv.load
            @apikey = ENV['SHOPIFY_API_KEY']
            @shopname = ENV['SHOPIFY_SHOP_NAME']
            @password = ENV['SHOPIFY_PASSWORD']

            @marika_key = ENV['MARIKA_API_KEY']
            @marika_shopname = ENV['MARIKA_SHOP_NAME']
            @marika_password = ENV['MARIKA_PASSWORD']

            @zobha_key = ENV['ZOBHA_API_KEY']
            @zobha_shopname = ENV['ZOBHA_SHOP_NAME']
            @zobha_password = ENV['ZOBHA_PASSWORD']

        end

        def get_yesterday
            my_now = Date.today
            my_yesterday = my_now -1

            puts my_now.strftime("%Y-%m-%d")
            puts my_yesterday.strftime("%Y-%m-%d")
        end

        def emergency_post_order
            api_key = "e8230337f0f45e3795b125d5aec1a081"
            password = "a3ed722374ae3e56b7eb3abeabd8cc0a"
            shopname = "marikastaging"
            ShopifyAPI::Base.site = "https://#{api_key}:#{password}@#{shopname}.myshopify.com/admin"

            order_hash = {"order" => {"email" => "tahniyatkazmi@gmail.com", "total_price" => "25.00", "line_items" => [{"variant_id" => 7266729164859, "product_id" => 586514956347, "sku" => 722457825660, "quantity" => 1, "price" => 25.00, "title" => "Amy Crop Hoodie", "properties" => [{"name" => "Final Sale", "value" => "true"}] } ], "customer" => { "first_name" => "Tahniyat", "last_name" => "Kazmi", "email" => "tahniyatkazmi@gmail.com"}, "billing_address" =>  { "first_name" => "Tahniyat", "last_name" => "Kazmi", "address1" => "207 Somewhere Street", "address2" => "", "phone" => "2135557780", "city" => "New York", "province" => "New York", "country" => "United States", "zip" => "90201"}, "shipping_address" => { "first_name" => "Tahniyat", "last_name" => "Kazmi", "address1" => "207 Somewhere Street", "address2" => "","phone" => "2135557780", "city" => "New York", "province" => "New York", "country" => "United States", "zip" => "90201" }  }, "shipping_lines" => [{ "title" => "Overnight", "price" => "24.95", "code" => "Overnight", "source" => "shopify", "phone" => nil, "requested_fulfillment_service_id" => nil, "delivery_category" => nil, "carrier_identifier" => nil?, "discounted_price" => "24.95", "discount_allocations" => [], "tax_lines" => [] } ] }

            myorder = ShopifyAPI::Order.create(order_hash)
            puts myorder.inspect
            



        end


        def find_marika_duplicate_skus

            File.delete('marika_duplicate_skus.csv') if File.exist?('marika_duplicate_skus.csv')
            mybad_file = File.open('marika_duplicate_skus.csv', 'w')
            mybad_file.write("Product_title, variant_sku, product_id, variant_id, variant_title, variant_price, variant_inventory_quantity, handle, published_scope, product_type, tags\n")

            sql_statement = "select count(marika_variants.variant_id), marika_variants.sku, marika_variants.title from marika_variants group by marika_variants.sku, marika_variants.title having count(marika_variants.variant_id) > 1"

            records_array = ActiveRecord::Base.connection.execute(sql_statement)

            records_array.each do |myrec|
                puts myrec.inspect
                num_duplicates = myrec['count']
                master_bad_sku = myrec['sku']
                more_sql = "select marika_variants.variant_id, marika_variants.title as var_title, marika_variants.price, marika_variants.sku, marika_variants.inventory_quantity, marika_variants.product_id, marika_products.handle, marika_products.title as prod_title, marika_products.tags, marika_products.published_scope, marika_products.product_type from marika_variants, marika_products where marika_products.product_id = marika_variants.product_id and  marika_variants.sku = #{myrec['sku']}"
                bad_individual_sku = ActiveRecord::Base.connection.execute(more_sql)
                puts "-------------"
                bad_individual_sku.each do |badsku|
                    puts badsku.inspect
                    #{"variant_id"=>6035287506971, "var_title"=>"HEATHER GRIFFIN / L", "price"=>"42.99", "sku"=>722457859825, "inventory_quantity"=>12, "product_id"=>574860886043, "handle"=>"mlj0229a", "prod_title"=>"Nadia Jacket", "tags"=>"40-50, Aqua Beat, cf-color-heather-griffin, cf-size-l, cf-size-m, cf-size-s, cf-size-xl, color-heather-griffin, size-l, size-xl", "published_scope"=>"web", "product_type"=>"Jackets"}
                    #Create variables for insertion into table
                    variant_id = badsku['variant_id']
                    variant_title = badsku['var_title']
                    variant_price = badsku['price']
                    variant_sku = badsku['sku']
                    variant_inventory_quantity = badsku['inventory_quantity']
                    product_id = badsku['product_id']
                    handle = badsku['handle']
                    product_title = badsku['prod_title']
                    tags = badsku['tags'].gsub(",", " ")
                    published_scope = badsku['published_scope']
                    product_type = badsku['product_type']

                    #mybad_file.write("Product_title, variant_sku, product_id, variant_id, variant_title, variant_price, variant_inventory_quantity, handle, published_scope, product_type, tags\n")

                    mybad_file.write("#{product_title}, #{variant_sku}, #{product_id}, #{variant_id}, #{variant_title}, #{variant_price}, #{variant_inventory_quantity}, #{handle}, #{published_scope}, #{product_type}, #{tags}\n")



                end
                puts "-------------"
                mybad_file.write("Bad Sku: #{master_bad_sku} has #{num_duplicates} duplicates\n")
                mybad_file.write("\n")
            end


        end

        def find_ellie_duplicate_skus

            File.delete('ellie_duplicate_skus.csv') if File.exist?('ellie_duplicate_skus.csv')
            mybad_file = File.open('ellie_duplicate_skus.csv', 'w')
            mybad_file.write("Product_title, variant_sku, product_id, variant_id, variant_title, variant_price, variant_inventory_quantity, handle, published_scope, product_type, tags\n")

            sql_statement = "select count(distinct ellie_variants.variant_id), ellie_variants.sku, ellie_variants.title from ellie_variants group by ellie_variants.sku, ellie_variants.title having count(ellie_variants.variant_id) > 1"

            records_array = ActiveRecord::Base.connection.execute(sql_statement)

            records_array.each do |myrec|
                puts myrec.inspect
                num_duplicates = myrec['count']
                master_bad_sku = myrec['sku']

                puts "my master_bad_sku = #{master_bad_sku}||||"

                #next if master_bad_sku == "" || master_bad_sku = nil || master_bad_sku = " "

                

                more_sql = "select ellie_variants.variant_id, ellie_variants.title as var_title, ellie_variants.price, ellie_variants.sku, ellie_variants.inventory_quantity, ellie_variants.product_id, ellie_products.handle, ellie_products.title as prod_title, ellie_products.tags, ellie_products.published_scope, ellie_products.product_type from ellie_variants, ellie_products where ellie_products.product_id = ellie_variants.product_id and  ellie_variants.sku = #{myrec['sku']}"
                bad_individual_sku = ActiveRecord::Base.connection.execute(more_sql)
                puts "-------------"
                bad_individual_sku.each do |badsku|
                    puts badsku.inspect
                    #{"variant_id"=>6035287506971, "var_title"=>"HEATHER GRIFFIN / L", "price"=>"42.99", "sku"=>722457859825, "inventory_quantity"=>12, "product_id"=>574860886043, "handle"=>"mlj0229a", "prod_title"=>"Nadia Jacket", "tags"=>"40-50, Aqua Beat, cf-color-heather-griffin, cf-size-l, cf-size-m, cf-size-s, cf-size-xl, color-heather-griffin, size-l, size-xl", "published_scope"=>"web", "product_type"=>"Jackets"}
                    #Create variables for insertion into table
                    variant_id = badsku['variant_id']
                    variant_title = badsku['var_title']
                    variant_price = badsku['price']
                    variant_sku = badsku['sku']
                    variant_inventory_quantity = badsku['inventory_quantity']
                    product_id = badsku['product_id']
                    handle = badsku['handle']
                    product_title = badsku['prod_title']
                    tags = badsku['tags'].gsub(",", " ")
                    published_scope = badsku['published_scope']
                    product_type = badsku['product_type']

                    #mybad_file.write("Product_title, variant_sku, product_id, variant_id, variant_title, variant_price, variant_inventory_quantity, handle, published_scope, product_type, tags\n")

                    mybad_file.write("#{product_title}, #{variant_sku}, #{product_id}, #{variant_id}, #{variant_title}, #{variant_price}, #{variant_inventory_quantity}, #{handle}, #{published_scope}, #{product_type}, #{tags}\n")



                end
                puts "-------------"
                mybad_file.write("Bad Sku: #{master_bad_sku} has #{num_duplicates} duplicates\n")
                mybad_file.write("\n")
            end


        end



        

        def provide_min_max(my_min, my_max)
            #puts "my_min = #{my_min}, #{my_max}"
            if (my_min.to_i == 0) && (my_max.to_i == 0)
                my_now = Date.today
                my_yesterday = my_now -1
                local_min = my_yesterday.strftime("%Y-%m-%dT00:00:00-04:00") 
                local_max = my_yesterday.strftime("%Y-%m-%dT23:58:00-4:00")
                stuff_to_return = {"my_min" => local_min, "my_max" => local_max}


            else
                stuff_to_return = {"my_min" => my_min, "my_max" => my_max}
            end
            #puts stuff_to_return.inspect
            return stuff_to_return
        end

        def get_orders(my_min, my_max)
            my_args = provide_min_max(my_min, my_max)
            my_min = my_args['my_min']
            my_max = my_args['my_max']
            puts "my_min = #{my_min}, my_max = #{my_max}"
            ShopifyAPI::Base.site = "https://#{@apikey}:#{@password}@#{@shopname}.myshopify.com/admin"
            order_count = ShopifyAPI::Order.count( created_at_min: my_min, created_at_max: my_max, status: 'any')
            puts "We have #{order_count} orders"

            EllieShopifyOrder.delete_all
            ActiveRecord::Base.connection.reset_pk_sequence!('ellie_shopify_orders')

            page_size = 250
            pages = (order_count / page_size.to_f).ceil

            1.upto(pages) do |page|
                orders = ShopifyAPI::Order.find(:all, params: {limit: 250, created_at_min: my_min, created_at_max: my_max, status: 'any', page: page})
                orders.each do |myorder|
                    puts "-----------------"
                    #puts myorder.inspect
                    puts myorder.customer.attributes['first_name'].inspect
                    puts "-----------------"
                    

                    my_address1 = myorder.billing_address.attributes['address1']
                    my_address2 = myorder.billing_address.attributes['address2']
                    if my_address1 =~ /,/
                        my_address1.gsub!(",", " ")
                    end

                    if my_address2 =~ /,/
                        my_address2.gsub!(",", " ")
                    end

                    puts "#{myorder.name}, #{myorder.created_at}, #{myorder.billing_address.attributes['first_name']},  #{myorder.billing_address.attributes['last_name']}, #{my_address1}, #{my_address2}, #{myorder.billing_address.attributes['city']}, #{myorder.billing_address.attributes['province_code']}, #{myorder.billing_address.attributes['zip']}, #{myorder.email}"
                    my_ellie_order = EllieShopifyOrder.create(order_name: myorder.name, created_at: myorder.created_at, email: myorder.email, first_name: myorder.billing_address.attributes['first_name'], last_name: myorder.billing_address.attributes['last_name'], billing_address1: my_address1, billing_address2: my_address1, city: myorder.billing_address.attributes['city'], state: myorder.billing_address.attributes['province_code'], zip: myorder.billing_address.attributes['zip'] )

                end
                puts "Done with Page #{page}"
                puts "Sleeping 4 secs"
                sleep 4
            end


            puts "All done with orders!"
        end

        def get_marika_orders(my_min, my_max)
            ShopifyAPI::Base.site = "https://#{@marika_key}:#{@marika_password}@#{@marika_shopname}.myshopify.com/admin"
            order_count = ShopifyAPI::Order.count( created_at_min: my_min, created_at_max: my_max, status: 'any')
            puts "We have for MARIKA #{order_count} orders"

            page_size = 250
            pages = (order_count / page_size.to_f).ceil

            MarikaShopifyOrder.delete_all
            ActiveRecord::Base.connection.reset_pk_sequence!('marika_shopify_orders')

            1.upto(pages) do |page|
                orders = ShopifyAPI::Order.find(:all, params: {limit: 250, created_at_min: my_min, created_at_max: my_max, status: 'any', page: page})
                orders.each do |myorder|
                    #puts myorder.inspect

                    my_address1 = myorder.billing_address.attributes['address1']
                    my_address2 = myorder.billing_address.attributes['address2']
                    if my_address1 =~ /\,/
                        my_address1.gsub!(",", " ")
                    end

                    if my_address2 =~ /\,/
                        my_address2.gsub!(",", " ")
                    end

                    puts "#{myorder.name}, #{myorder.created_at}, #{myorder.billing_address.attributes['first_name']},  #{myorder.billing_address.attributes['last_name']}, #{my_address1}, #{my_address2}, #{myorder.billing_address.attributes['city']}, #{myorder.billing_address.attributes['province_code']}, #{myorder.billing_address.attributes['zip']}"
                    my_marika_order = MarikaShopifyOrder.create(order_name: myorder.name, created_at: myorder.created_at, email: myorder.email, first_name: myorder.billing_address.attributes['first_name'], last_name: myorder.billing_address.attributes['last_name'], billing_address1: my_address1, billing_address2: my_address2, city: myorder.billing_address.attributes['city'], state: myorder.billing_address.attributes['province_code'], zip: myorder.billing_address.attributes['zip'] )

                end
                puts "Done with Page #{page}"
                puts "Sleeping 4 secs"
                sleep 4
            end


            puts "All done with orders!"
        end


        def get_ellie_collect
            ShopifyAPI::Base.site = "https://#{@apikey}:#{@password}@#{@shopname}.myshopify.com/admin"
            collect_count = ShopifyAPI::Collect.count()
            puts "We have #{collect_count} collects"

            page_size = 250
            pages = (collect_count / page_size.to_f).ceil

            EllieCollect.delete_all
            ActiveRecord::Base.connection.reset_pk_sequence!('ellie_collects')

            1.upto(pages) do |page|
                mycollects = ShopifyAPI::Collect.find(:all, params: {limit: 250, page: page})
                #puts mycollects.inspect
                mycollects.each do |myc|
                    puts myc.attributes.inspect
                    my_local_collect = EllieCollect.create(collect_id: myc.attributes['id'], collection_id: myc.attributes['collection_id'], product_id: myc.attributes['product_id'], featured: myc.attributes['featured'], created_at: myc.attributes['created_at'], updated_at: myc.attributes['updated_at'], position: myc.attributes['position'], sort_value: myc.attributes['sort_value'] )

                end
                puts "------------------"
                puts "Done with page #{page}"
                puts "sleeping 4 secs"
                sleep 4

            end
        end

        def get_ellie_collections
            ShopifyAPI::Base.site = "https://#{@apikey}:#{@password}@#{@shopname}.myshopify.com/admin"
            collection_count = ShopifyAPI::CustomCollection.count()
            puts "We have #{collection_count} collections for Ellie"

            page_size = 250
            pages = (collection_count / page_size.to_f).ceil
            EllieCustomCollection.delete_all
            ActiveRecord::Base.connection.reset_pk_sequence!('ellie_custom_collections')


            1.upto(pages) do |page|
                mycollection = ShopifyAPI::CustomCollection.find(:all, params: {limit: 250, page: page})
                #puts mycollection.inspect
                mycollection.each do |mycoll|
                    puts mycoll.attributes.inspect
                    my_custom_collection = EllieCustomCollection.create(collection_id: mycoll.attributes['id'], handle: mycoll.attributes['handle'], title: mycoll.attributes['title'], updated_at: mycoll.attributes['updated_at'], body_html: mycoll.attributes['body_html'], published_at: mycoll.attributes['published_at'], sort_order: mycoll.attributes['sort_order'], template_suffix: mycoll.attributes['template_suffix'], published_scope: mycoll.attributes['published_scope'])

                end

                puts "----------------"
                puts "Done with page #{page}"
                puts "Sleeping 4 secs"
                sleep 4
            end

        end

        def get_marika_products
            ShopifyAPI::Base.site = "https://#{@marika_key}:#{@marika_password}@#{@marika_shopname}.myshopify.com/admin"
            product_count = ShopifyAPI::Product.count()
            puts "We have #{product_count} products for Marika, BABY!"

            page_size = 250
            pages = (product_count / page_size.to_f).ceil

            MarikaProduct.delete_all
            ActiveRecord::Base.connection.reset_pk_sequence!('marika_products')
            MarikaVariant.delete_all
            ActiveRecord::Base.connection.reset_pk_sequence!('marika_variants')

            1.upto(pages) do |page|
                myproducts = ShopifyAPI::Product.find(:all, params: {limit: 250, page: page})
                myproducts.each do |myprod|
                    puts "-----------"
                    puts myprod.inspect
                    myprodid = myprod.attributes['id']
                    myprodtitle = myprod.attributes['title']
                    myprod_type = myprod.attributes['product_type']
                    mycreated_at = myprod.attributes['created_at']
                    myupdated_at = myprod.attributes['updated_at']
                    myhandle = myprod.attributes['handle']
                    mytemplate_suffix = myprod.attributes['template_suffix']
                    mybody_html = myprod.attributes['body_html']
                    mytags = myprod.attributes['tags']
                    mypublished_scope = myprod.attributes['published_scope']
                    myvendor = myprod.attributes['vendor']
                    myoptions = myprod.attributes['options'][0].attributes
                    #puts myprod.attributes['options'][0].attributes.inspect
                    #puts myprod.attributes['images'].inspect
                    myimages_array = Array.new
                    myprod.attributes['images'].each do |mystuff|
                        #puts mystuff.inspect
                        myimages_array << mystuff.attributes
                    end
                    #puts myprod.variants.inspect
                    myvariants = myprod.variants
                    myvariants.each do |myvar|
                        puts "++++++++++++"
                        #puts myvar.inspect
                        puts myvar.attributes.inspect
                        puts myvar.prefix_options[:product_id]
                        puts "++++++++++++"
                        myproduct_id = myvar.prefix_options[:product_id]
                        myvariant_id = myvar.attributes['id']
                        myvartitle = myvar.attributes['title']
                        myprice = myvar.attributes['price']
                        mysku = myvar.attributes['sku']
                        myposition = myvar.attributes['position']
                        myinventory_policy = myvar.attributes['inventory_policy']
                        mycompare_at_price = myvar.attributes['compare_at_price']
                        myfulfillment_service = myvar.attributes['fulfillment_service']
                        myinventory_management = myvar.attributes['inventory_management']
                        myoption1 = myvar.attributes['option1']
                        myoption2 = myvar.attributes['option2']
                        myoption3 = myvar.attributes['option3']
                        mycreated_at = myvar.attributes['created_at']
                        myupdated_at = myvar.attributes['updated_at']
                        mytaxable = myvar.attributes['taxable']
                        mybarcode = myvar.attributes['barcode']
                        myweight_unit = myvar.attributes['weight_unit']
                        myweight = myvar.attributes['weight']
                        myinventory_quantity = myvar.attributes['inventory_quantity']
                        myimage_id = myvar.attributes['image_id']
                        mygrams = myvar.attributes['grams']
                        myinventory_item_id = myvar.attributes['inventory_item_id']
                        mytax_code = myvar.attributes['tax_code']
                        myold_inventory_quantity = myvar.attributes['old_inventory_quantity']
                        myrequires_shipping = myvar.attributes['requires_shipping']
                        myellie_variant = MarikaVariant.create(variant_id: myvariant_id, product_id: myproduct_id, title: myvartitle, price: myprice, sku: mysku, position: myposition, inventory_policy: myinventory_policy, compare_at_price: mycompare_at_price, fulfillment_service: myfulfillment_service, inventory_management: myinventory_management, option1: myoption1, option2: myoption2, option3: myoption3, created_at: mycreated_at, updated_at: myupdated_at, taxable: mytaxable, barcode: mybarcode, weight_unit: myweight_unit, weight: myweight, inventory_quantity: myinventory_quantity, image_id: myimage_id, grams: mygrams, inventory_item_id: myinventory_item_id, tax_code: mytax_code, old_inventory_quantity: myold_inventory_quantity, requires_shipping: myrequires_shipping  )

                    end
                    #puts myimages_array.inspect
                    my_ellie_product = MarikaProduct.create(product_id: myprodid, title: myprodtitle, product_type: myprod_type, created_at: mycreated_at, updated_at: myupdated_at, handle: myhandle, template_suffix: mytemplate_suffix, body_html: mybody_html, tags: mytags, published_scope: mypublished_scope, vendor: myvendor, options: myoptions, image: myimages_array)
                    puts "-----------"

                end

                puts "Done with Page #{page}"
                puts "Sleeping 4 secs"
                sleep 4
            end
            puts "All done with products"


        end

        def get_zobha_products
            ShopifyAPI::Base.site = "https://#{@zobha_key}:#{@zobha_password}@#{@zobha_shopname}.myshopify.com/admin"
            puts "https://#{@zobha_key}:#{@zobha_password}@#{@zobha_shopname}.myshopify.com/admin"
            product_count = ShopifyAPI::Product.count()
            puts "We have #{product_count} products for Zobha, BABY!"

            page_size = 250
            pages = (product_count / page_size.to_f).ceil

            ZobhaProduct.delete_all
            ActiveRecord::Base.connection.reset_pk_sequence!('marika_products')
            ZobhaVariant.delete_all
            ActiveRecord::Base.connection.reset_pk_sequence!('marika_variants')

            1.upto(pages) do |page|
                myproducts = ShopifyAPI::Product.find(:all, params: {limit: 250, page: page})
                myproducts.each do |myprod|
                    puts "-----------"
                    puts myprod.inspect
                    myprodid = myprod.attributes['id']
                    myprodtitle = myprod.attributes['title']
                    myprod_type = myprod.attributes['product_type']
                    mycreated_at = myprod.attributes['created_at']
                    myupdated_at = myprod.attributes['updated_at']
                    myhandle = myprod.attributes['handle']
                    mytemplate_suffix = myprod.attributes['template_suffix']
                    mybody_html = myprod.attributes['body_html']
                    mytags = myprod.attributes['tags']
                    mypublished_scope = myprod.attributes['published_scope']
                    myvendor = myprod.attributes['vendor']
                    myoptions = myprod.attributes['options'][0].attributes
                    #puts myprod.attributes['options'][0].attributes.inspect
                    #puts myprod.attributes['images'].inspect
                    myimages_array = Array.new
                    myprod.attributes['images'].each do |mystuff|
                        #puts mystuff.inspect
                        myimages_array << mystuff.attributes
                    end
                    #puts myprod.variants.inspect
                    myvariants = myprod.variants
                    myvariants.each do |myvar|
                        puts "++++++++++++"
                        #puts myvar.inspect
                        puts myvar.attributes.inspect
                        puts myvar.prefix_options[:product_id]
                        puts "++++++++++++"
                        myproduct_id = myvar.prefix_options[:product_id]
                        myvariant_id = myvar.attributes['id']
                        myvartitle = myvar.attributes['title']
                        myprice = myvar.attributes['price']
                        mysku = myvar.attributes['sku']
                        myposition = myvar.attributes['position']
                        myinventory_policy = myvar.attributes['inventory_policy']
                        mycompare_at_price = myvar.attributes['compare_at_price']
                        myfulfillment_service = myvar.attributes['fulfillment_service']
                        myinventory_management = myvar.attributes['inventory_management']
                        myoption1 = myvar.attributes['option1']
                        myoption2 = myvar.attributes['option2']
                        myoption3 = myvar.attributes['option3']
                        mycreated_at = myvar.attributes['created_at']
                        myupdated_at = myvar.attributes['updated_at']
                        mytaxable = myvar.attributes['taxable']
                        mybarcode = myvar.attributes['barcode']
                        myweight_unit = myvar.attributes['weight_unit']
                        myweight = myvar.attributes['weight']
                        myinventory_quantity = myvar.attributes['inventory_quantity']
                        myimage_id = myvar.attributes['image_id']
                        mygrams = myvar.attributes['grams']
                        myinventory_item_id = myvar.attributes['inventory_item_id']
                        mytax_code = myvar.attributes['tax_code']
                        myold_inventory_quantity = myvar.attributes['old_inventory_quantity']
                        myrequires_shipping = myvar.attributes['requires_shipping']
                        myellie_variant = ZobhaVariant.create(variant_id: myvariant_id, product_id: myproduct_id, title: myvartitle, price: myprice, sku: mysku, position: myposition, inventory_policy: myinventory_policy, compare_at_price: mycompare_at_price, fulfillment_service: myfulfillment_service, inventory_management: myinventory_management, option1: myoption1, option2: myoption2, option3: myoption3, created_at: mycreated_at, updated_at: myupdated_at, taxable: mytaxable, barcode: mybarcode, weight_unit: myweight_unit, weight: myweight, inventory_quantity: myinventory_quantity, image_id: myimage_id, grams: mygrams, inventory_item_id: myinventory_item_id, tax_code: mytax_code, old_inventory_quantity: myold_inventory_quantity, requires_shipping: myrequires_shipping  )

                    end
                    #puts myimages_array.inspect
                    my_ellie_product = ZobhaProduct.create(product_id: myprodid, title: myprodtitle, product_type: myprod_type, created_at: mycreated_at, updated_at: myupdated_at, handle: myhandle, template_suffix: mytemplate_suffix, body_html: mybody_html, tags: mytags, published_scope: mypublished_scope, vendor: myvendor, options: myoptions, image: myimages_array)
                    puts "-----------"

                end

                puts "Done with Page #{page}"
                puts "Sleeping 4 secs"
                sleep 4
            end
            puts "All done with Zobha products"


        end





        def get_ellie_products
            ShopifyAPI::Base.site = "https://#{@apikey}:#{@password}@#{@shopname}.myshopify.com/admin"
            product_count = ShopifyAPI::Product.count()
            puts "We have #{product_count} products for Ellie"

            page_size = 250
            pages = (product_count / page_size.to_f).ceil

            EllieProduct.delete_all
            ActiveRecord::Base.connection.reset_pk_sequence!('ellie_products')
            EllieVariant.delete_all
            ActiveRecord::Base.connection.reset_pk_sequence!('ellie_variants')

            1.upto(pages) do |page|
                myproducts = ShopifyAPI::Product.find(:all, params: {limit: 250, page: page})
                myproducts.each do |myprod|
                    puts "-----------"
                    myprodid = myprod.attributes['id']
                    myprodtitle = myprod.attributes['title']
                    myprod_type = myprod.attributes['product_type']
                    mycreated_at = myprod.attributes['created_at']
                    myupdated_at = myprod.attributes['updated_at']
                    myhandle = myprod.attributes['handle']
                    mytemplate_suffix = myprod.attributes['template_suffix']
                    mybody_html = myprod.attributes['body_html']
                    mytags = myprod.attributes['tags']
                    mypublished_scope = myprod.attributes['published_scope']
                    myvendor = myprod.attributes['vendor']
                    myoptions = myprod.attributes['options'][0].attributes
                    #puts myprod.attributes['options'][0].attributes.inspect
                    #puts myprod.attributes['images'].inspect
                    myimages_array = Array.new
                    myprod.attributes['images'].each do |mystuff|
                        #puts mystuff.inspect
                        myimages_array << mystuff.attributes
                    end
                    #puts myprod.variants.inspect
                    myvariants = myprod.variants
                    myvariants.each do |myvar|
                        puts "++++++++++++"
                        #puts myvar.inspect
                        puts myvar.attributes.inspect
                        puts myvar.prefix_options[:product_id]
                        puts "++++++++++++"
                        myproduct_id = myvar.prefix_options[:product_id]
                        myvariant_id = myvar.attributes['id']
                        mytitle = myvar.attributes['title']
                        myprice = myvar.attributes['price']
                        mysku = myvar.attributes['sku']
                        myposition = myvar.attributes['position']
                        myinventory_policy = myvar.attributes['inventory_policy']
                        mycompare_at_price = myvar.attributes['compare_at_price']
                        myfulfillment_service = myvar.attributes['fulfillment_service']
                        myinventory_management = myvar.attributes['inventory_management']
                        myoption1 = myvar.attributes['option1']
                        myoption2 = myvar.attributes['option2']
                        myoption3 = myvar.attributes['option3']
                        mycreated_at = myvar.attributes['created_at']
                        myupdated_at = myvar.attributes['updated_at']
                        mytaxable = myvar.attributes['taxable']
                        mybarcode = myvar.attributes['barcode']
                        myweight_unit = myvar.attributes['weight_unit']
                        myweight = myvar.attributes['weight']
                        myinventory_quantity = myvar.attributes['inventory_quantity']
                        myimage_id = myvar.attributes['image_id']
                        mygrams = myvar.attributes['grams']
                        myinventory_item_id = myvar.attributes['inventory_item_id']
                        mytax_code = myvar.attributes['tax_code']
                        myold_inventory_quantity = myvar.attributes['old_inventory_quantity']
                        myrequires_shipping = myvar.attributes['requires_shipping']
                        myellie_variant = EllieVariant.create(variant_id: myvariant_id, product_id: myproduct_id, title: mytitle, price: myprice, sku: mysku, position: myposition, inventory_policy: myinventory_policy, compare_at_price: mycompare_at_price, fulfillment_service: myfulfillment_service, inventory_management: myinventory_management, option1: myoption1, option2: myoption2, option3: myoption3, created_at: mycreated_at, updated_at: myupdated_at, taxable: mytaxable, barcode: mybarcode, weight_unit: myweight_unit, weight: myweight, inventory_quantity: myinventory_quantity, image_id: myimage_id, grams: mygrams, inventory_item_id: myinventory_item_id, tax_code: mytax_code, old_inventory_quantity: myold_inventory_quantity, requires_shipping: myrequires_shipping  )

                    end
                    #puts myimages_array.inspect
                    my_ellie_product = EllieProduct.create(product_id: myprodid, title: myprodtitle, product_type: myprod_type, created_at: mycreated_at, updated_at: myupdated_at, handle: myhandle, template_suffix: mytemplate_suffix, body_html: mybody_html, tags: mytags, published_scope: mypublished_scope, vendor: myvendor, options: myoptions, image: myimages_array)
                    puts "-----------"

                end

                puts "Done with Page #{page}"
                puts "Sleeping 4 secs"
                sleep 4
            end
            puts "All done with products"


        end


        def get_special_ellie_orders(my_min, my_max)
            ShopifyAPI::Base.site = "https://#{@apikey}:#{@password}@#{@shopname}.myshopify.com/admin"
            order_count = ShopifyAPI::Order.count( created_at_min: my_min, created_at_max: my_max, status: 'any')
            puts "We have #{order_count} orders"

            #Headers for CSV
            column_header = ["order_name", "first_name", "last_name", "created_at", "billing_address1", "billing_address2", "city", "state", "zip", "email", "sku"]

            page_size = 250
            pages = (order_count / page_size.to_f).ceil

            #delete old file
            File.delete('ellie_order_skus.csv') if File.exist?('ellie_order_skus.csv')

            #Code for bad Rose All Day orders
            File.delete('bad_rose_all_day_orders.csv') if File.exist?('bad_rose_all_day_orders.csv')
            mybad_file = File.open('bad_rose_all_day_orders.csv', 'w')
            mybad_file.write("Order #, Bad Sku, created_at, updated_at, customer_email, first, last, note\n")

            CSV.open('ellie_order_skus.csv','a+', :write_headers=> true, :headers => column_header) do |hdr|
                column_header = nil

            1.upto(pages) do |page|
                orders = ShopifyAPI::Order.find(:all, params: {limit: 250, created_at_min: my_min, created_at_max: my_max, status: 'any', page: page})
                orders.each do |myorder|
                    puts "***************"
                    #new code for ghazal
                    #puts myorder.inspect
                    skus_per_order = 0
                    my_address1 = myorder.billing_address.attributes['address1']
                    my_address2 = myorder.billing_address.attributes['address2']
                    if my_address1 =~ /,/
                        my_address1.gsub!(",", " ")
                    end

                    if my_address2 =~ /,/
                        my_address2.gsub!(",", " ")
                    end

                    #puts myorder.attributes['line_items'].inspect
                    myline_items = myorder.attributes['line_items']
                    myline_items.each do |myline|
                        puts "------------"
                        puts myline.attributes.inspect
                        myproperties = myline.attributes['properties']
                        myprod_collection = ""
                        myleggings = ""
                        mysports_bra = ""
                        mytops = ""
                        myproperties.each do |myprops|
                            local_prop = myprops.attributes
                            
                            puts local_prop.inspect
                            case local_prop['name']
                            when "product_collection"
                                myprod_collection = local_prop['value']
                            when "leggings", "leggings:", "legging"
                                myleggings = local_prop['value'].upcase
                            when "sports-bra", "sports-bra:", "sports-bras", "sports_bra"
                                mysports_bra = local_prop['value'].upcase
                            when "top", "top:", "tops:"
                                mytops = local_prop['value'].upcase
                            when "tops"
                                mytops = local_prop['value'].upcase

                            end
                            
                        end
                        puts "product_collection = #{myprod_collection}, leggings = #{myleggings}, tops = #{mytops}, sports_bra = #{mysports_bra}"
                        puts "------------"
                        if (myline.attributes['variant_title'] == "") || (myline.attributes['variant_title'] == nil  )
                            puts "YOOOOWZA got a Collection Product Folks!"
                            new_skus = Array.new
                            new_skus = get_collection_skus(myprod_collection, myleggings, mytops, mysports_bra)
                            puts new_skus.inspect
                            
                            #puts myorder.name

                            #code here to check for order information bad Rose All Day.
                            #XS sku = 722457993949
                            #XL sku = 722457993987
                            if (new_skus.include? 722457993949) || (new_skus.include? 722457993987)
                                #write out Bad Order to separate file
                                if new_skus.include? 722457993949
                                    my_bad_sku_size = "XS"
                                else
                                    my_bad_sku_size = "XL"
                                end
                                mybad_file.write("#{myorder.name}, #{my_bad_sku_size}, #{myorder.created_at}, #{myorder.updated_at}, #{myorder.email}, #{myorder.billing_address.attributes['first_name']}, #{myorder.billing_address.attributes['last_name']}, #{myorder.note}\n")

                            end

                            
                            puts "#{myorder.name}, #{myorder.created_at}, #{myorder.billing_address.attributes['first_name']},  #{myorder.billing_address.attributes['last_name']}, #{my_address1}, #{my_address2}, #{myorder.billing_address.attributes['city']}, #{myorder.billing_address.attributes['province_code']}, #{myorder.billing_address.attributes['zip']}, #{myorder.email}"
                            
                            new_skus.each do |mysku|

                                csv_data_out = [myorder.name, myorder.billing_address.attributes['first_name'], myorder.billing_address.attributes['last_name'],myorder.created_at, my_address1, my_address2, myorder.billing_address.attributes['city'],myorder.billing_address.attributes['province_code'], myorder.billing_address.attributes['zip'], myorder.email, mysku  ]
                                hdr << csv_data_out
                                skus_per_order += 1
                            end
                        else
                            puts "PUUUUSSSSSSHHHHH this sku only"
                            sku_for_this_line_item = myline.attributes['sku']
                            title_for_this_line_item = myline.attributes['title']
                            puts sku_for_this_line_item
                            
                            
                            puts "#{myorder.name}, #{myorder.created_at}, #{myorder.billing_address.attributes['first_name']},  #{myorder.billing_address.attributes['last_name']}, #{my_address1}, #{my_address2}, #{myorder.billing_address.attributes['city']}, #{myorder.billing_address.attributes['province_code']}, #{myorder.billing_address.attributes['zip']}, #{myorder.email}"

                            csv_data_out = [myorder.name, myorder.billing_address.attributes['first_name'], myorder.billing_address.attributes['last_name'], myorder.created_at, my_address1, my_address2, myorder.billing_address.attributes['city'],myorder.billing_address.attributes['province_code'], myorder.billing_address.attributes['zip'], myorder.email, sku_for_this_line_item  ]
                                hdr << csv_data_out
                                skus_per_order += 1
                        end
                    end
                    puts "**************"
                    #write out skus per order
                    csv_data_out = [myorder.name, skus_per_order]
                    hdr << csv_data_out
                end

            end

            end
            #end of csv part
            mybad_file.close

        end

        def get_collection_skus(myprod_collection, myleggings, mytops, mysports_bra)
            skus_to_return = Array.new
            if myprod_collection != ""
                my_base_products = Array.new
                
                mylocalcol = EllieCustomCollection.find_by_title(myprod_collection)
                if !mylocalcol.nil?
                    puts mylocalcol.inspect
                    puts mylocalcol.collection_id
                    my_collects = EllieCollect.where("collection_id = ?", mylocalcol.collection_id)
                    my_collects.each do |myc|
                        puts myc.inspect
                        mytemp_product = EllieProduct.find_by_product_id(myc.product_id)
                        puts mytemp_product.product_type
                        my_prod_type = mytemp_product.product_type.downcase
                        my_prod_type = my_prod_type.gsub(" ", "-")
                        my_base_products << {"product_id" => myc.product_id, "product_type" => my_prod_type }
                    end
                    puts "Products are #{my_base_products.inspect}"
                    
                    my_base_products.each do |mybase|
                        case mybase['product_type']
                        when "tops"
                            puts "tops = #{mytops}"
                            my_variant = EllieVariant.where("product_id = ? and option1 = ?", mybase['product_id'], mytops).first
                            if my_variant.nil?
                                puts "can't find variant something wrong"
                                skus_to_return << "BADSKU"
                                #exit
                            else
                            puts my_variant.inspect
                            skus_to_return << my_variant.sku
                            end
                        when "sports-bra"
                            puts "sports-bra = #{mysports_bra}"
                            my_variant = EllieVariant.where("product_id = ? and option1 = ?", mybase['product_id'], mysports_bra).first
                            #puts my_variant.inspect
                            if my_variant.nil?
                                puts "can't find variant something wrong"
                                skus_to_return << "BADSKU"
                                #exit
                            else
                            skus_to_return << my_variant.sku
                            end
                        when "leggings"
                            puts "leggings = #{myleggings}"
                            my_variant = EllieVariant.where("product_id = ? and option1 = ?", mybase['product_id'], myleggings).first
                            #puts my_variant.inspect
                            if my_variant.nil?
                                puts "can't find variant something wrong"
                                skus_to_return << "BADSKU"
                                #exit
                            else
                            skus_to_return << my_variant.sku
                            end
                        when "equipment"
                            my_variant = EllieVariant.where("product_id = ?", mybase['product_id']).first
                            puts my_variant.inspect
                            skus_to_return << my_variant.sku

                        when "accessories"
                            my_variant = EllieVariant.where("product_id = ?", mybase['product_id']).first
                            puts my_variant.inspect
                            skus_to_return << my_variant.sku


                        end

                    end

                else
                    puts "Could not find product_collection, can't get skus"
                    skus_to_return << "Cannot_find_Product_Collection"
                end


            else
                puts "No collection, can't get skus"
                skus_to_return << "Product_Collection_Empty"
            end
            

            #stuff_to_return = ['412', '567', '348']
            return skus_to_return

        end


        def jennifer_products
            File.delete('jen_products_body_html.csv') if File.exist?('jen_products_body_html.csv')
            mybad_file = File.open('jen_products_body_html.csv', 'w')
            mybad_file.write("Product_Title, Product_Handle, Product_Body_HTML\n")

            CSV.foreach('tracy_jen_request_products_html.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
             product = row['Product']
             product_id = row['Product_id']   
             puts "#{product}, #{product_id}"
             my_ellie_product = EllieProduct.find_by_product_id(product_id)
             puts my_ellie_product.body_html
             puts my_ellie_product.title
             puts my_ellie_product.handle
             my_body = my_ellie_product.body_html.gsub("\n", '')
             mybad_file.write("#{my_ellie_product.title}, #{my_ellie_product.handle}, #{my_body}\n")
            

            end
            mybad_file.close


        end


    end
end