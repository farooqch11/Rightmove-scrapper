class Order < ApplicationRecord
  enum status: [:pushed_to_shopify, :fulfilled]


 def mark_fulfillment(data)
   endpoint = "#{ENV["MIRAKL_URL"]}/api/orders/"+orderid+"/tracking"
   response = HTTParty.put(endpoint,  :body => data.to_json,:headers => { "Content-Type" => 'application/json', "Authorization" => "#{ENV["SHOP_KEY"]}"})
   puts response.body

   # Confirm the shipment
   endpoint2 = "#{ENV["MIRAKL_URL"]}/api/orders/"+self.madewell_id+"/ship"
   response2 = HTTParty.put(endpoint2,:headers => { "Content-Type" => 'application/json', "Authorization" => "#{ENV["SHOP_KEY"]}"})
   self.status = Order.statuses[:fulfilled]
   self.save!
 end

end
