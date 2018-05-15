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

        end

        def get_yesterday
            my_now = Date.today
            my_yesterday = my_now -1

            puts my_now.strftime("%Y-%m-%d")
            puts my_yesterday.strftime("%Y-%m-%d")
        end

        def get_orders(my_min, my_max)
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
                    #puts myorder.inspect

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
                    mytitle = myprod.attributes['title']
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
                    my_ellie_product = EllieProduct.create(product_id: myprodid, title: mytitle, product_type: myprod_type, created_at: mycreated_at, updated_at: myupdated_at, handle: myhandle, template_suffix: mytemplate_suffix, body_html: mybody_html, tags: mytags, published_scope: mypublished_scope, vendor: myvendor, options: myoptions, image: myimages_array)
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

            CSV.open('ellie_order_skus.csv','a+', :write_headers=> true, :headers => column_header) do |hdr|
                column_header = nil

            1.upto(pages) do |page|
                orders = ShopifyAPI::Order.find(:all, params: {limit: 250, created_at_min: my_min, created_at_max: my_max, status: 'any', page: page})
                orders.each do |myorder|
                    puts "***************"

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
                                myleggings = local_prop['value']
                            when "sports-bra", "sports-bra:", "sports-bras"
                                mysports_bra = local_prop['value']
                            when "top", "top:", "tops:"
                                mytops = local_prop['value']
                            when "tops"
                                mytops = local_prop['value']

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
                            
                            puts "#{myorder.name}, #{myorder.created_at}, #{myorder.billing_address.attributes['first_name']},  #{myorder.billing_address.attributes['last_name']}, #{my_address1}, #{my_address2}, #{myorder.billing_address.attributes['city']}, #{myorder.billing_address.attributes['province_code']}, #{myorder.billing_address.attributes['zip']}, #{myorder.email}"
                            
                            new_skus.each do |mysku|

                                csv_data_out = [myorder.name, myorder.billing_address.attributes['first_name'], myorder.billing_address.attributes['last_name'],myorder.created_at, my_address1, my_address2, myorder.billing_address.attributes['city'],myorder.billing_address.attributes['province_code'], myorder.billing_address.attributes['zip'], myorder.email, mysku  ]
                                hdr << csv_data_out
                            end
                        else
                            puts "PUUUUSSSSSSHHHHH this sku only"
                            sku_for_this_line_item = myline.attributes['sku']
                            title_for_this_line_item = myline.attributes['title']
                            puts sku_for_this_line_item
                            
                            
                            puts "#{myorder.name}, #{myorder.created_at}, #{myorder.billing_address.attributes['first_name']},  #{myorder.billing_address.attributes['last_name']}, #{my_address1}, #{my_address2}, #{myorder.billing_address.attributes['city']}, #{myorder.billing_address.attributes['province_code']}, #{myorder.billing_address.attributes['zip']}, #{myorder.email}"

                            csv_data_out = [myorder.name, myorder.billing_address.attributes['first_name'], myorder.billing_address.attributes['last_name'],myorder.created_at, my_address1, my_address2, myorder.billing_address.attributes['city'],myorder.billing_address.attributes['province_code'], myorder.billing_address.attributes['zip'], myorder.email, sku_for_this_line_item  ]
                                hdr << csv_data_out

                        end
                    end
                    puts "**************"
                end

            end

            end
            #end of csv part

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
                                exit
                            end
                            puts my_variant.inspect
                            skus_to_return << my_variant.sku
                        when "sports-bra"
                            puts "sports-bra = #{mysports_bra}"
                            my_variant = EllieVariant.where("product_id = ? and option1 = ?", mybase['product_id'], mysports_bra).first
                            puts my_variant.inspect
                            skus_to_return << my_variant.sku
                        when "leggings"
                            puts "leggings = #{myleggings}"
                            my_variant = EllieVariant.where("product_id = ? and option1 = ?", mybase['product_id'], myleggings).first
                            puts my_variant.inspect
                            skus_to_return << my_variant.sku

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


    end
end