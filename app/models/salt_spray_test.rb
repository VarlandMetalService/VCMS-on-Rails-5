class SaltSprayTest < ApplicationRecord

  # Default scoping.
  default_scope { where 'deleted_at IS NULL' }

  # Associations.
  has_one       :salt_spray_part
  belongs_to    :salt_spray_tester,
                class_name: 'User',
                foreign_key: 'put_on_by',
                optional: true
  belongs_to    :white_spot_reporter,
                class_name: 'User',
                foreign_key: 'marked_white_by',
                optional: true
  belongs_to    :red_spot_reporter,
                class_name: 'User',
                foreign_key: 'marked_red_by',
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
  scope :with_put_on_at_gte, lambda { |reference_time|
    where('salt_spray_tests.put_on_at >= ?', reference_time.to_date)
  }
  scope :with_put_on_at_lte, lambda { |reference_time|
    where('salt_spray_tests.put_on_at <= ?', reference_time.to_date)
  }
  scope :sorted_by, ->(sort_option) {
    order sort_option
  }

  def self.options_for_put_on_by
    users = User.where id: SaltSprayTest.distinct.pluck(:put_on_by)
    users.map { |u| [u.full_name, u.id] }
  end

  def delete_test(current_user_id)
    self.deleted_at = DateTime.current
    self.deleted_by = current_user_id
    save
  end

  def update_spot(current_user_id, spot_type)
    if spot_type == 'white'
      self.marked_white_at = Date.current
      self.marked_white_by = current_user_id
    elsif(spot_type == 'red')
      self.marked_red_at = Date.current
      self.marked_red_by = current_user_id
    end
  end

  def get_pass_fail(spot_type)
    case spot_type
    when 'white'
      spec_test = self.salt_spray_part.white_spec
      spot_date = self.marked_white_at
    when 'red'
      spec_test = self.salt_spray_part.red_spec
      spot_date = self.marked_red_at
    end

    if spec_test == 0
      return
    end

    if calculate_rust_hours(spot_date) <= spec_test
      return 'spec-passed'
    else
      return 'spec-failed'
    end
  end

  def calculate_rust_hours(spot_date)
    if spot_date
      return subtract_time_get_hours(spot_date.to_time, self.put_on_at.to_time)
    else
      return subtract_time_get_hours(Date.current.to_time, self.put_on_at)
    end
  end

  def subtract_time_get_hours(time_off, time_on)
    return ((time_off - time_on)/1.hour).floor
  end

  def get_spot_found_value(value, spot_type)
    case spot_type
    when 'white'
      return 'N/A' if !self.white_spec_exists?
      spot_date = self.marked_white_at
      reporter = self.white_spot_reporter
    when 'red'
      return 'N/A' if !self.red_spec_exists?
      spot_date = self.marked_red_at
      reporter = self.red_spot_reporter
    end

    if spot_date
      if value == 'date'
        return spot_date.strftime('%m/%d/%Y')
      else
        return reporter.full_name
      end
    else
      return '<br />'.html_safe
    end
  end

  def white_spec_exists?
    return self.salt_spray_part.white_spec != 0
  end

  def red_spec_exists?
    return self.salt_spray_part.red_spec != 0
  end

end
