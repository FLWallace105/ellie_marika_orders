class AlterEllieVariants < ActiveRecord::Migration[5.2]
  def up
    change_column :ellie_variants, :sku, :string
  end

  def down
    change column :ellie_variants, :sku, :bigint

  end



end
