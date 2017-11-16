class SaltSprayPart < ApplicationRecord

  # Associations
  belongs_to :salt_spray_test

  validates :shop_order_number,
            presence: true,
            length: { is: 6 }



end
