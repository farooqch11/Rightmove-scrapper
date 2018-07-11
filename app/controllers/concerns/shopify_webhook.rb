module ShopifyWebhook
  extend ActiveSupport::Concern

  def verify_webhook(data, request)
    hmac_header = request.env['HTTP_X_SHOPIFY_HMAC_SHA256']
    calculated_hmac = Base64.strict_encode64(OpenSSL::HMAC.digest('sha256', ENV["SHOPIFY_WEBHOOK_TOKEN"], data))
    ActiveSupport::SecurityUtils.secure_compare(calculated_hmac, hmac_header)
  end

end