require 'rubygems'

namespace :inventory do
  desc "Populate Inventory for first time to have variants"
  task :populate_inventory => :environment do

    @shop_url = "https://#{ENV["SHOPIFY_API_KEY"]}:#{ENV["SHOPIFY_PASSWORD"]}@#{ENV["SHOPIFY_SHOP"]}.myshopify.com/admin"
    ShopifyAPI::Base.site = @shop_url
    page = 1
    loop do
      variants = ShopifyAPI::Variant.find(:all, params: {limit: 250, page: page})
      break if variants.empty?
      variants.each do |variant|
        Inventory.create(sku: variant.sku,
                                    shopify_variant: variant.id,
                                    product_id: variant.prefix_options[:product_id],
                                    name: variant.title)
      end
      page = page + 1
    end
  end
end