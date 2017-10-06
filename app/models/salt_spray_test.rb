class SaltSprayTest < ApplicationRecord

  # Default scoping.
  default_scope { where 'is_deleted IS FALSE' }

  # Associations.
  has_one       :salt_spray_part
  belongs_to    :salt_spray_tester,
                class_name: 'User',
                foreign_key: 'put_on_by',
                optional: true
  belongs_to    :white_spot_reporter,
                class_name: 'User',
                foreign_key: 'who_called_white',
                optional: true
  belongs_to    :red_spot_reporter,
                class_name: 'User',
                foreign_key: 'who_called_red',
                optional: true
  has_many      :attachments,
                as: :attachable,
                dependent: :destroy
  has_many      :salt_spray_process_steps,
                inverse_of: :salt_spray_test

  accepts_nested_attributes_for   :attachments,
                                    reject_if: :all_blank,
                                    allow_destroy: true
  accepts_nested_attributes_for   :salt_spray_part
  accepts_nested_attributes_for   :salt_spray_process_steps,
                                    reject_if: :all_blank,
                                    allow_destroy: true

  # Scopes.
  scope :with_shop_order_number, lambda { |shop_orders|
    joins(:salt_spray_part).where("salt_spray_parts.shop_order_number like ?", "#{shop_orders}%")
  }
  scope :with_put_on_by, ->(values) {
    where put_on_by: [*values]
  }
  scope :with_date_on_gte, lambda { |reference_time|
    where('salt_spray_tests.date_on >= ?', reference_time.to_date)
  }
  scope :with_date_on_lte, lambda { |reference_time|
    where('salt_spray_tests.date_on <= ?', reference_time.to_date)
  }
  scope :sorted_by, ->(sort_option) {
    order sort_option
  }

  def self.options_for_put_on_by
    users = User.where id: SaltSprayTest.distinct.pluck(:put_on_by)
    users.map { |u| [u.full_name, u.id] }
  end

  def delete_test(current_user_id)
    self.is_deleted = true
    self.deleted_by = current_user_id
    save
  end

  def update_spot(current_user_id, spot_type)
    if spot_type == 'white'
      self.date_w_white = DateTime.current
      self.who_called_white = current_user_id
    elsif(spot_type == 'red')
      self.date_w_red = DateTime.current
      self.who_called_red = current_user_id
    end
  end

  def calculate_rust_hours(spot_type)
    if spot_type == 'white' and self.date_w_white
      return subtract_time_get_hours(self.date_w_white.to_time, self.date_on.to_time)
    elsif spot_type == 'red' and self.date_w_red
      return subtract_time_get_hours(self.date_w_red.to_time, self.date_on.to_time)
    else
      return subtract_time_get_hours(DateTime.current.to_time, self.date_on.to_time)
    end
  end

  def subtract_time_get_hours(time_off, time_on)
    return ((time_off - time_on)/1.hour).floor
  end

  def get_white_value(value)
    if self.salt_spray_part.white_spec != 0
      if self.date_w_white
        if value == 'date'
          return self.date_w_white.strftime('%m/%d/%Y')
        else
          return self.white_spot_reporter.full_name
        end
      else
        return ''
      end
    end
    return 'N/A'
  end

  def get_red_value(value)
    if self.salt_spray_part.red_spec != 0
      if self.date_w_red
        if value == 'date'
          return self.date_w_red.strftime('%m/%d/%Y')
        else
          return self.red_spot_reporter.full_name
        end
      else
        return ''
      end
    end
    return 'N/A'
  end

end
