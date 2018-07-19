class AddNewFieldsToProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :house_no, :string
    add_column :properties, :street_name, :string
    add_column :properties, :city, :string
    add_column :properties, :post_code, :string
    add_column :properties, :letter_sent, :boolean,default: false
    add_column :properties, :unfindable, :boolean,default: false
    add_column :properties, :complete, :boolean,default: false
  end
end
