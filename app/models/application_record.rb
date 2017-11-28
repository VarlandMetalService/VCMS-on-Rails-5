require 'rest-client'

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.options_for_department
    [
      ['Dept. 3', '3'],
      ['Dept. 4', '4'],
      ['Dept. 5', '5'],
      ['Dept. 6', '6'],
      ['Dept. 7', '7'],
      ['Dept. 8', '8'],
      ['Dept. 10', '10'],
      ['Dept. 12', '12'],
      ['Waste Water', '30']
    ]
  end

  def self.options_for_plating_department
    [
      ['Dept. 3', '3'],
      ['Dept. 4', '4'],
      ['Dept. 5', '5'],
      ['Dept. 8', '8'],
      ['Dept. 12', '12']
    ]
  end

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
