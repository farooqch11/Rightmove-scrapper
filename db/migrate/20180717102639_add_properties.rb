class AddProperties < ActiveRecord::Migration[5.2]
  def change
    create_table :properties do |t|
      t.string :title
      t.string :asking_price
      t.string :location
      t.string :last_sold_price
      t.string :upload_date
      t.string :url

      t.timestamps
    end
  end
end
