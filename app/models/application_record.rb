require 'rest-client'

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # TODO: Use Net::HTTP instead of RestClient
  def get_shop_order_details(shop_order = '')
    begin
      response = RestClient.get 'http://api.varland.com/v1/so_details?so=' + shop_order.to_s

      return JSON.parse(response)
    rescue => e
      logger.debug("ERROR (ApplicationController - shop_order_details): #{e.message}")
      false
    end
  end
end
