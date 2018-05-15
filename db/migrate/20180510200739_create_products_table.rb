class CreateProductsTable < ActiveRecord::Migration[5.2]
  def up
    create_table :ellie_products do |t|
      t.bigint :product_id
      t.string :title
      t.string :product_type
      t.datetime :created_at
      t.datetime :updated_at
      t.string :handle
      t.string :template_suffix
      t.text :body_html
      t.string :tags
      t.string :published_scope
      t.jsonb :image
      t.string :vendor
      t.jsonb :options



    end
  end

  def down
    drop_table :ellie_products
  end
end
