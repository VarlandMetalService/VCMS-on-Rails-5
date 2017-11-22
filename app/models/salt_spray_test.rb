class SaltSprayTest < ApplicationRecord

  before_save :standardize_times
  before_create :add_shop_order_details

  # Default scoping.
  default_scope { where 'deleted_at IS NULL' }

  # Associations.
  belongs_to    :salt_spray_tester,
                class_name: 'User',
                foreign_key: 'put_on_by',
                optional: true
  belongs_to    :pulled_off_by,
                class_name: 'User',
                foreign_key: 'pulled_off_by',
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
  has_one       :comment,
                as: :commentable,
                dependent: :destroy
  has_many      :salt_spray_process_steps,
                inverse_of: :salt_spray_test

  accepts_nested_attributes_for   :attachments,
                                    reject_if: :all_blank,
                                    allow_destroy: true
  accepts_nested_attributes_for   :comment,
                                    reject_if: :all_blank,
                                    allow_destroy: true
  accepts_nested_attributes_for   :salt_spray_process_steps,
                                    reject_if: :all_blank,
                                    allow_destroy: true

  # Scopes.
  scope :with_shop_order_number, lambda { |shop_orders|
    where("shop_order_number like ?", "#{shop_orders}%")
  }
  scope :with_put_on_by, ->(values) {
    where put_on_by: [*values]
  }
  scope :with_part_number, lambda { |part_numbers|
    where("part_number like ?", "#{part_numbers}%")
  }
  scope :with_put_on_at_gte, lambda { |reference_time|
    where 'put_on_at >= ?', reference_time.to_date
  }
  scope :with_put_on_at_lte, lambda { |reference_time|
    where 'put_on_at < ?', reference_time.to_date + 1
  }
  scope :sorted_by, ->(sort_option) {
    order sort_option
  }

  def self.options_for_part_number
    SaltSprayTest.distinct.pluck(:part_number).sort!
  end

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
      spec_test = self.white_spec
      spot_date = self.marked_white_at
    when 'red'
      spec_test = self.red_spec
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
      return subtract_time_get_hours(Date.current.to_time.noon, self.put_on_at)
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
    return self.white_spec != 0
  end

  def red_spec_exists?
    return self.red_spec != 0
  end

private

  def standardize_times
    if self.put_on_at.present?
      self.put_on_at = self.put_on_at.noon
    end
    if self.marked_white_at.present?
      self.marked_white_at = self.marked_white_at.noon
    end
    if self.marked_red_at.present?
      self.marked_red_at = self.marked_red_at.noon
    end
    if self.pulled_off_at.present?
      self.pulled_off_at = self.pulled_off_at.noon
    end
  end

  def add_shop_order_details
    if so_details = get_shop_order_details(self.shop_order_number)
      begin
        self.customer = so_details['customer']
        self.process_code = so_details['process']
        self.part_number = so_details['part']
        self.sub = so_details['sub']
        self.white_spec = so_details['saltSprayWhite']
        self.red_spec = so_details['saltSprayRed']
        self.part_area = so_details['pieceArea']
        self.density = so_details['poundsPerCubic']
        self.load_weight = so_details['loadWeight']

      rescue => e
        self.errors.add(:salt_spray_test, "invalid shop order number.")
        throw :abort
      end
    else
      self.errors.add(:salt_spray_test, "unable to find shop order details.")
      throw :abort
    end
  end

end
