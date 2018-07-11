class CreateVariantsAndSkus < ActiveRecord::Migration[5.2]
  def change
    create_table :inventories do |t|
      t.string :sku
      t.string :name
      t.bigint :shopify_variant
      t.bigint :product_id

      t.timestamps
    end
  end
end
