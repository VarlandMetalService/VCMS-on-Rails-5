class SaltSprayPart < ApplicationRecord

  # Associations
  belongs_to :salt_spray_test

  validates :shop_order_number,
            presence: true,
            length: { is: 6 }

  def self.options_for_part_number
    SaltSprayPart.distinct.pluck(:part_number).sort!
  end

end
