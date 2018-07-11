require 'rubygems'
require 'shopify_api'

class OrderWorker

  include Sidekiq::Worker
  sidekiq_options :retry => 5

  def perform
    # Configure the Shopify connection
    @shop_url = "https://#{ENV["SHOPIFY_API_KEY"]}:#{ENV["SHOPIFY_PASSWORD"]}@#{ENV["SHOPIFY_SHOP"]}.myshopify.com/admin"
    ShopifyAPI::Base.site = @shop_url


    @all_orders = []
    @all_orders_ids = []
    file = File.read('allskus.json')
    madewell_products = JSON.parse(file)

# In production, will need to hit the API for all accepted orders:
# or11 = HTTParty.get("#{ENV["MIRAKL_URL"]}/api/orders?order_state_codes=SHIPPING", { headers: {"Authorization" => "#{ENV["SHOP_KEY"]}"} })
# Example of what the API will return:
    file2 = File.read('sample2.json')
    or11 = JSON.parse(file2)

# Loop through all the orders, push the IDs into a var / array
# Take those orders and loop through them, accepting them 1 by 1
    or11['orders'].each do |theorder|
      # OR21 = accept the order
      orderid = theorder['order_id']
      order = Order.find_by_madewell_id(orderid)
      if order.present?
        next
      end
      # Loop through the line items and crossref with a CSV/hash that has variant id next to SKU
      # order_lines
      line_items = Array.new
      theorder['order_lines'].each do |madewelllineitems|
        quantity = madewelllineitems['quantity']
        sku = madewelllineitems['product_sku']
        orderlineid = madewelllineitems['order_line_id']
        # search a hash to find the SKU and corresponding variant ID
        variantid = madewell_products[0][sku]
        # Right now hard coding a specific variant ID. Ignore.
        # variantid = '277519499270'
        # print variantid
        thehash = {'variant_id': variantid,
                   'quantity': quantity ,
                   'Name': madewelllineitems['product_title'],
                   'title': madewelllineitems['product_title'],
                   'price':  madewelllineitems['price'],
                   'sku': sku
        }
        line_items.push(thehash)
      end

      # Customer Info
      unless theorder['customer']['shipping_address'].nil?
        firstname = theorder['customer']['shipping_address']['firstname']
        lastname = theorder['customer']['shipping_address']['lastname']
        address1 = theorder['customer']['shipping_address']['street_1']
        address2 = theorder['customer']['shipping_address']['street_2']
        city = theorder['customer']['shipping_address']['city']
        state = theorder['customer']['shipping_address']['state']
        zip = theorder['customer']['shipping_address']['zip_code']
        phone = theorder['customer']['shipping_address']['phone']
        country = theorder['customer']['shipping_address']['country']
        shipping_address = ["province": state, "address1": address1, "address2": address2, "city": city, "country": country, "first_name": firstname, "last_name": lastname,  "phone": phone, "zip": zip]

        # How to tell which shipping Madewell Order is using, and translate that into the Shopify Shipping Info
        shipping_type = theorder['shipping_type_label']
        if shipping_type == 'UPS Ground'
          shipping_lines = [ "code": "Free Shipping","price": "0.00", "source": "shopify", "title": "Free Shipping" ]
        elsif shipping_type == 'UPS Overnight'
          shipping_lines = [ "code": "	FedEx Standard Overnight (1 business day)","price": "0.00", "source": "shopify", "title": "	FedEx Standard Overnight (1 business day)" ]
        elsif shipping_type == 'UPS two Day'
          shipping_lines = [ "code": "FedEx Express Saver (3 business days)","price": "0.00", "source": "shopify", "title": "	FedEx Express Saver (3 business days)" ]
        elsif shipping_type == 'SUREPOST'
          shipping_lines = [ "code": "Free Shipping","price": "0.00", "source": "shopify", "title": "Free Shipping" ]
        else
          shipping_lines = [ "code": "Free Shipping","price": "0.00", "source": "shopify", "title": "Free Shipping" ]
        end

        # push the order info to a hash
        the_order = { :line_items => line_items, :shipping_address => shipping_address, :orderid => orderid, :shipping_lines => shipping_lines ,:email=>theorder['customer']['email'] }

        @all_orders.push(the_order)
      end

    end


# next - place the orders
# Create the Order in Shopify
    @all_orders.each do |madewellorder|
      financial_status = 'paid'
      madewellorderid = madewellorder[:orderid]
      tags = "Madewell, " + madewellorderid
      note_attributes = [{  "name": "Madewell Order", "value": madewellorderid }]
      line_items = madewellorder[:line_items]
      shipping_address = madewellorder[:shipping_address][0]
      shipping_lines = madewellorder[:shipping_lines]
      customer =  {"first_name": shipping_address[:first_name] + shipping_address[:last_name], "email": madewellorder[:email]}
      order = ShopifyAPI::Order.create(line_items: line_items, tags: tags, note_attributes: note_attributes, billing_address: shipping_address, shipping_address: shipping_address, customer: customer, shipping_lines: shipping_lines )
      order.save
      order = Order.create(name: order.name,details: madewellorder,madewell_id:madewellorder[:orderid],shopify_id: order.id,status: Order.statuses[:pushed_to_shopify])
      # thehash = {:madewellid =>madewellorderid, :shopifyid=>order.id}
      # @all_orders_ids.push(thehash)
      sleep(0.12)
    end

  end


end
