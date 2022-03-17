class FixMarikaVariantsTable < ActiveRecord::Migration[5.2]
  def up
    change_column :marika_variants, :sku, :string
  end

  def down
    change column :marika_variants, :sku, :bigint

  end
end
