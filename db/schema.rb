# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_06_20_232811) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ellie_collects", force: :cascade do |t|
    t.bigint "collect_id"
    t.bigint "collection_id"
    t.bigint "product_id"
    t.boolean "featured", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "position"
    t.string "sort_value"
  end

  create_table "ellie_custom_collections", force: :cascade do |t|
    t.bigint "collection_id"
    t.string "handle"
    t.string "title"
    t.datetime "updated_at"
    t.text "body_html"
    t.datetime "published_at"
    t.string "sort_order"
    t.string "template_suffix"
    t.string "published_scope"
  end

  create_table "ellie_products", force: :cascade do |t|
    t.bigint "product_id"
    t.string "title"
    t.string "product_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "handle"
    t.string "template_suffix"
    t.text "body_html"
    t.string "tags"
    t.string "published_scope"
    t.jsonb "image"
    t.string "vendor"
    t.jsonb "options"
  end

  create_table "ellie_shopify_orders", force: :cascade do |t|
    t.string "order_name"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at"
    t.string "billing_address1"
    t.string "billing_address2"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "email"
  end

  create_table "ellie_variants", force: :cascade do |t|
    t.bigint "variant_id"
    t.string "title"
    t.decimal "price", precision: 10, scale: 2
    t.bigint "sku"
    t.integer "position"
    t.string "inventory_policy"
    t.decimal "compare_at_price", precision: 10, scale: 2
    t.bigint "product_id"
    t.string "fulfillment_service"
    t.string "inventory_management"
    t.string "option1"
    t.string "option2"
    t.string "option3"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "taxable"
    t.string "barcode"
    t.decimal "weight", precision: 10, scale: 2
    t.string "weight_unit"
    t.integer "inventory_quantity"
    t.bigint "image_id"
    t.integer "grams"
    t.bigint "inventory_item_id"
    t.string "tax_code"
    t.integer "old_inventory_quantity"
    t.boolean "requires_shipping"
  end

  create_table "marika_products", force: :cascade do |t|
    t.bigint "product_id"
    t.string "title"
    t.string "product_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "handle"
    t.string "template_suffix"
    t.text "body_html"
    t.string "tags"
    t.string "published_scope"
    t.jsonb "image"
    t.string "vendor"
    t.jsonb "options"
  end

  create_table "marika_shopify_orders", force: :cascade do |t|
    t.string "order_name"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at"
    t.string "billing_address1"
    t.string "billing_address2"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "email"
  end

  create_table "marika_variants", force: :cascade do |t|
    t.bigint "variant_id"
    t.string "title"
    t.decimal "price", precision: 10, scale: 2
    t.bigint "sku"
    t.integer "position"
    t.string "inventory_policy"
    t.decimal "compare_at_price", precision: 10, scale: 2
    t.bigint "product_id"
    t.string "fulfillment_service"
    t.string "inventory_management"
    t.string "option1"
    t.string "option2"
    t.string "option3"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "taxable"
    t.string "barcode"
    t.decimal "weight", precision: 10, scale: 2
    t.string "weight_unit"
    t.integer "inventory_quantity"
    t.bigint "image_id"
    t.integer "grams"
    t.bigint "inventory_item_id"
    t.string "tax_code"
    t.integer "old_inventory_quantity"
    t.boolean "requires_shipping"
  end

  create_table "pending_people", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "first_name", limit: 125
    t.string "last_name", limit: 125
    t.string "email", limit: 125
  end

  create_table "shipped_people", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "first", limit: 125
    t.string "last", limit: 125
    t.string "customer_email", limit: 125
  end

  create_table "zobha_products", force: :cascade do |t|
    t.bigint "product_id"
    t.string "title"
    t.string "product_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "handle"
    t.string "template_suffix"
    t.text "body_html"
    t.string "tags"
    t.string "published_scope"
    t.jsonb "image"
    t.string "vendor"
    t.jsonb "options"
  end

  create_table "zobha_variants", force: :cascade do |t|
    t.bigint "variant_id"
    t.string "title"
    t.decimal "price", precision: 10, scale: 2
    t.bigint "sku"
    t.integer "position"
    t.string "inventory_policy"
    t.decimal "compare_at_price", precision: 10, scale: 2
    t.bigint "product_id"
    t.string "fulfillment_service"
    t.string "inventory_management"
    t.string "option1"
    t.string "option2"
    t.string "option3"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "taxable"
    t.string "barcode"
    t.decimal "weight", precision: 10, scale: 2
    t.string "weight_unit"
    t.integer "inventory_quantity"
    t.bigint "image_id"
    t.integer "grams"
    t.bigint "inventory_item_id"
    t.string "tax_code"
    t.integer "old_inventory_quantity"
    t.boolean "requires_shipping"
  end

end
