class SaltSprayTest < ApplicationRecord
  serialize :checked_by_archive, Array

  attr_accessor :manual_edit

  before_save :archive_checked_by
  before_save :check_for_sample
  before_save :standardize_times, unless: :manual_edit
  before_create :add_shop_order_details

  default_scope { where 'deleted_at IS NULL' }

  self.per_page = 30

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
  scope :with_customer, lambda { |customers|
    where 'customer like ?', "#{customers}%"
  }
  scope :with_part_number, lambda { |part_numbers|
    where("part_number like ?", "#{part_numbers}%")
  }
  scope :with_process_code, lambda { |process_code|
    child_codes = get_child_process_codes(process_code)
    if child_codes
      child_codes.unshift(process_code)
      process_code = child_codes
    end
    where(process_code: process_code)
  }
  scope :with_flag, lambda {|is_flagged|
    if is_flagged == '1'
      where "flagged_by IS NOT NULL"
    end
  }
  scope :with_sample, lambda {|is_sample|
    if is_sample == '1'
      where "is_sample = ?", true
    end
  }
  scope :with_has_comments, lambda {|has_comments|
    if has_comments == '1'
      joins(:comments).distinct
    end
  }
  scope :with_has_attachments, lambda {|has_attachments|
    if has_attachments == '1'
      joins(:comments => :attachments).distinct
    end
  }
  scope :with_dept, lambda { |dept|
    where 'dept like ?', "#{dept}%"
  }
  scope :with_white_spec, lambda { |white_spec|
    where 'white_spec like ?', "#{white_spec}%"
  }
  scope :with_red_spec, lambda { |red_spec|
    where 'red_spec like ?', "#{red_spec}%"
  }
  scope :with_chromate, ->(query) {
    joins(:salt_spray_process_steps).distinct.where('chromate like ?', "%#{query}%")
  }
  scope :with_comments, ->(query) {
    joins(:comments).distinct.where('content like ?', "%#{query}%")
  }
  scope :with_sub, lambda { |sub_id|
    where("sub like ?", "%#{sub_id}%")
  }
  scope :with_put_on_at_gte, lambda { |reference_time|
    where 'put_on_at >= ?', reference_time.to_date
  }
  scope :with_put_on_at_lte, lambda { |reference_time|
    where 'put_on_at < ?', reference_time.to_date + 1
  }
  scope :with_pulled_off_at_gte, lambda { |reference_time|
    where 'pulled_off_at >= ?', reference_time.to_date
  }
  scope :with_pulled_off_at_lte, lambda { |reference_time|
    where 'pulled_off_at < ?', reference_time.to_date + 1
  }
  scope :with_marked_white_at_gte, lambda { |reference_time|
    where 'marked_white_at >= ?', reference_time.to_date
  }
  scope :with_marked_white_at_lte, lambda { |reference_time|
    where 'marked_white_at < ?', reference_time.to_date + 1
  }
  scope :with_marked_white_by, ->(values) {
    where marked_white_by: [*values]
  }
  scope :with_marked_red_at_gte, lambda { |reference_time|
    where 'marked_red_at >= ?', reference_time.to_date
  }
  scope :with_marked_red_at_lte, lambda { |reference_time|
    where 'marked_red_at < ?', reference_time.to_date + 1
  }
  scope :with_marked_red_by, ->(values) {
    where marked_red_by: [*values]
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
    distinct.where.not(part_number: [nil, '']).limit(100).pluck(:part_number).sort!
  end

  def self.options_for_process_code
    result = self.distinct.where.not(process_code: [nil, '']).limit(100).pluck(:process_code).sort!
    result.map { |p|
      child_code_options = get_child_process_codes(get_parent_process_code(p))
      if child_code_options.length > 0
        [get_parent_process_code(p) + ", " + child_code_options.join(", "), get_parent_process_code(p)]
      else
        [get_parent_process_code(p), get_parent_process_code(p)]
      end
    }.uniq
  end

  def self.options_for_customer
    distinct.where.not(customer: [nil, '']).limit(100).pluck(:customer).sort!
  end

  def self.options_for_dept
    self.distinct.where.not(dept: nil).limit(100).pluck(:dept).sort!
  end

  def self.options_for_chromate
    process_steps = SaltSprayProcessStep.distinct.where salt_spray_test_id: self.distinct.pluck(:id)
    process_steps.map { |p| p.chromate }
  end

  def self.options_for_put_on_by
    users = User.where id: SaltSprayTest.distinct.pluck(:put_on_by)
    users.map { |u| [u.full_name, u.id] }
  end

  def self.options_for_pulled_off_by
    users = User.where id: SaltSprayTest.distinct.pluck(:pulled_off_by)
    users.map { |u| [u.full_name, u.id] }
  end

  def self.options_for_marked_red_by
    users = User.where id: self.distinct.pluck(:marked_red_by)
    users.map { |u| [u.full_name, u.id] }
  end

  def self.options_for_marked_white_by
    users = User.where id: self.distinct.pluck(:marked_white_by)
    users.map { |u| [u.full_name, u.id] }
  end

  def self.options_for_sorted_by
    [
      ['Date On (oldest first)', 'put_on_at'],
      ['Date On (newest first)', 'put_on_at DESC']
    ]
  end

  def self.options_for_archived_sorted_by
    [
      ['Date On (newest first)', 'put_on_at DESC'],
      ['Date On (oldest first)', 'put_on_at'],
    ]
  end

  def delete_test(current_user_id)
    self.deleted_at = DateTime.current
    self.deleted_by = current_user_id
    save
  end

  def update_spot(current_user_id, spot_type)
    if spot_type == 'white'
      self.marked_white_at = DateTime.current.change(sec: 0)
      self.marked_white_by = current_user_id
    elsif spot_type == 'red'
      self.marked_red_at = DateTime.current.change(sec: 0)
      self.marked_red_by = current_user_id
    end
  end

  def get_pass_fail(spot_type, pass_only = false)
    case spot_type
    when 'white'
      spec_test = self.white_spec
      spot_date = self.marked_white_at
    when 'red'
      spec_test = self.red_spec
      spot_date = self.marked_red_at
    end

    if spec_test.nil? || spec_test == 0 #|| spot_date.nil?
      return
    end

    if calculate_rust_hours(spot_date) >= spec_test
      "<i class='fa fa-check text-success'></i>".html_safe
    else
      if !pass_only
        "<i class='fa fa-close text-danger'></i>".html_safe
      end
    end
  end

  def calculate_rust_hours(spot_date)
    if spot_date
      return subtract_time_get_hours(spot_date.to_time, self.put_on_at.to_time)
    else
      return subtract_time_get_hours(DateTime.current.to_time, self.put_on_at)
    end
  end

  def subtract_time_get_hours(time_off, time_on)
    return ((time_off - time_on)/1.hour).floor
  end

  def get_spot_found_value(value, spot_type)
    case spot_type
    when 'white'
      spot_date = self.marked_white_at
      reporter = self.white_spot_reporter
    when 'red'
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
    return true # Temporary until we decide on intended functionality
    # self.is_sample || (self.white_spec == 0 && self.red_spec == 0)
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

  def get_last_comment
    self.comments.reverse_order.limit(1).to_a.first.content if self.comments.count > 0
  end

  def self.get_parent_process_code(process_code)
    case process_code
    when 'HN', 'SHN'
      return 'LN'
    when 'STZ'
      return 'TZ'
    when 'SZF'
      return 'ZF'
    when 'SZN'
      return 'ZN'
    else
      return process_code
    end
  end

  def self.get_child_process_codes(process_code)
    case process_code
    when 'LN'
      return ['HN', 'SHN']
    when 'TZ'
      return ['STZ']
    when 'ZF'
      return ['SZF']
    when 'ZN'
      return ['SZN']
    else
      return []
    end
  end

private

  def standardize_times
    if self.put_on_at.present? && self.put_on_at_changed?
      self.put_on_at = self.put_on_at.noon - 1.hour
    end
    if self.marked_white_at.present? && (self.white_spec_exists? && self.white_spec >= 24) && self.marked_white_at_changed?
      self.marked_white_at = self.marked_white_at.noon - 1.hour
    end
    if self.marked_red_at.present? && (self.red_spec_exists? && self.red_spec >= 24) && self.marked_red_at_changed?
      self.marked_red_at = self.marked_red_at.noon - 1.hour
    end
    if self.pulled_off_at.present? && self.pulled_off_at_changed?
      self.pulled_off_at = self.pulled_off_at.noon - 1.hour
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
          self.white_spec = so_details['saltSprayWhite'] if self.white_spec == 0
          self.red_spec = so_details['saltSprayRed'] if self.red_spec == 0
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

  def archive_checked_by
    if self.checked_by
      self.checked_by_archive << self.checked_by
    end
  end

  def check_for_sample
    if self.is_custom_order?
      self.is_sample = true
    end
  end

end
