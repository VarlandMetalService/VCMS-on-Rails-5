class SaltSprayTest < ApplicationRecord

  before_save :standardize_times
  before_create :add_shop_order_details

  default_scope { where 'deleted_at IS NULL' }

  belongs_to    :salt_spray_tester,
                class_name: 'User',
                foreign_key: 'put_on_by',
                optional: true
  belongs_to    :test_completed_by,
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
  has_many      :comments,
                as: :commentable,
                dependent: :destroy
  has_many      :salt_spray_process_steps,
                inverse_of: :salt_spray_test

  accepts_nested_attributes_for   :comments,
                                    reject_if: :all_blank,
                                    allow_destroy: true
  accepts_nested_attributes_for   :salt_spray_process_steps,
                                    reject_if: :all_blank,
                                    allow_destroy: true

  scope :with_shop_order_number, lambda { |shop_orders|
    where("shop_order_number like ?", "#{shop_orders}%")
  }
  scope :with_put_on_by, ->(values) {
    where put_on_by: [*values]
  }
  scope :with_part_number, lambda { |part_numbers|
    where("part_number like ?", "#{part_numbers}%")
  }
  scope :with_process_code, lambda { |process_code|
    where "process_code = ?", "#{process_code}"
  }
  scope :with_comments, ->(query) {
    SaltSprayTest.joins(:comments).distinct.where('content like ?', "%#{query}%")
  }
  scope :with_sample, lambda {|is_sample|
    where "is_sample = ?", "#{is_sample}"
  }
  scope :with_has_comments, lambda {|has_comments|
    if has_comments == '1'
      joins(:comments)
    end
  }
  scope :with_has_attachments, lambda {|has_attachments|
    if has_attachments == '1'
      joins(:comments)
    end
  }
  scope :with_put_on_at_gte, lambda { |reference_time|
    where 'put_on_at >= ?', reference_time.to_date
  }
  scope :with_put_on_at_lte, lambda { |reference_time|
    where 'put_on_at < ?', reference_time.to_date + 1
  }
  scope :with_customer, lambda { |customers|
    where 'customer like ?', "#{customers}%"
  }
  scope :sorted_by, ->(sort_option) {
    order sort_option
  }
  scope :active, -> {
    where 'pulled_off_at IS NULL'
  }
  scope :archived, -> {
    where 'pulled_off_at IS NOT NULL'
  }

  def self.options_for_part_number
    distinct.pluck(:part_number).sort!
  end

  def self.options_for_process_code
    distinct.pluck(:process_code).sort!
  end

  def self.options_for_customer
    distinct.pluck(:customer).sort!
  end

  def self.options_for_put_on_by
    users = User.where id: SaltSprayTest.distinct.pluck(:put_on_by)
    users.map { |u| [u.full_name, u.id] }
  end

  def self.options_for_sorted_by
    [
      ['Date (oldest first)', 'put_on_at'],
      ['Date (newest first)', 'put_on_at DESC']
    ]
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

    if spec_test.nil? || spec_test == 0
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
    self.white_spec != 0
  end

  def red_spec_exists?
    self.red_spec != 0
  end

  def can_edit_spec?
    self.is_sample || (self.white_spec == 0 && self.red_spec == 0)
  end

  def is_custom_order?
    self.shop_order_number == 111
  end

  def ready_to_archive?
    self.marked_white_at && self.marked_red_at
  end

  def marked_white?
    self.marked_white_at && self.white_spot_reporter
  end

  def marked_red?
    self.marked_red_at && self.red_spot_reporter
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
    if !is_custom_order?
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

end
