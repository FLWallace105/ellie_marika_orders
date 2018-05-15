class CreateEllieOrder < ActiveRecord::Migration[5.2]
  def up
    create_table :ellie_shopify_orders do |t|
      t.string :order_name
      t.string :first_name
      t.string :last_name
      t.datetime :created_at
      t.string :billing_address1
      t.string :billing_address2
      t.string :city
      t.string :state
      t.string :zip
      t.string :email
      

    end
  end

  def down
    drop_table :ellie_shopify_orders
  end
end
