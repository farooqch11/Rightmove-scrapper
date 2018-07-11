class OrdersController < ApplicationController
  skip_before_action :verify_authenticity_token ,only: [:update_order_status]
  include ShopifyWebhook



  def update_order_status
    request.body.rewind
    data = request.body.read
    verified = verify_webhook(data, request)
    order_json = JSON.parse(data)
    @order = Order.where(name: order_json['name']).first
    if verified && @order.present?
      puts @order
      @order.delay(:retry => false).mark_fulfillment(order_json)
      head :ok
    else
      head :error
    end
  end
end
