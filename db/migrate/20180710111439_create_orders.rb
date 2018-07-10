class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.string :name
      t.text :order_detail
      t.string :madewell_id
      t.bigint :shopify_id
      t.integer :status
      t.decimal :price
      t.string :customer_name
      t.jsonb :details, default: '{}'

      t.timestamps
    end
    add_index  :orders, :details, using: :gin
  end
end
