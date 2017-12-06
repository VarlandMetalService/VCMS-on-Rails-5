class TimeclockRecord < ApplicationRecord
  attr_accessor :submit_location

  before_validation :check_datetime_format
  before_save :check_for_buffer
  after_commit :update_user_status

  default_scope { where 'is_deleted IS FALSE' }

  belongs_to :user
  belongs_to :reason_code, optional: true

  validates :user,
            presence: true
  validates :record_type,
            presence: true
  validates :record_timestamp,
            presence: true
  validates :reason_code,
            presence: true,
            if: :desktop_submit
  validates :notes,
            presence: { message: "is required for this Reason Code"},
            if: lambda { |o| :desktop_submit && o.reason_code && o.reason_code.requires_notes? }

  scope :with_week, ->(values) {
    where('record_timestamp >= ? AND record_timestamp <= ?', Period.find_by_id(values).period_start_date, Period.find_by_id(values).period_end_date - 1)
  }
  scope :with_employee, ->(values) {
    where user_id: [*values]
  }
  scope :with_notes, ->(has_notes) {
    if has_notes == '1'
      where('record_type = ?', 'Notes')
    else
      where('record_type != ?', 'Notes')
    end
  }

  def self.options_for_period
    Period.where('is_closed IS FALSE').order('period_start_date').map { |p| ["#{p.period_start_date.strftime('%m/%d/%Y')} - #{p.period_end_date.strftime('%m/%d/%Y')}", p.id] }
  end

  def self.options_for_record_type
    [
      ['Start Work', 'Start Work'],
      ['End Work', 'End Work'],
      ['Start Break', 'Start Break'],
      ['End Break', 'End Break'],
      ['Notes', 'Notes']
    ]
  end

  def self.options_for_notes
    [
      ['Only Notes', '1'],
      ['Hide Notes', '2']
    ]
  end

private

  def check_datetime_format
    if self.record_timestamp.nil?
      errors.add(:record_timestamp, 'must be a valid date/time')
      throw :abort
    end
  end

  def check_for_buffer
    buffer = 10.seconds
    buffer_min = [1, 16, 31, 46]
    self.record_timestamp -= buffer if self.record_timestamp.sec <= buffer && buffer_min.include?(self.record_timestamp.min)
  end

  def update_user_status
    new_record = TimeclockRecord.where('user_id = ? AND record_type != ?', user_id, 'Notes').order("record_timestamp").last
    if new_record.nil?
      self.user.update_attribute(:current_status, 'in')
      return
    end

    case new_record.record_type
    when 'Start Work', 'End Break'
      user.update_attribute(:current_status, 'in') if user.current_status != 'in'
    when 'End Work'
      user.update_attribute(:current_status, 'out') if user.current_status != 'out'
    when 'Start Break'
      user.update_attribute(:current_status, 'break') if user.current_status != 'break'
    end
  end

  def soft_delete
    self.is_deleted = true
    save
  end

  def desktop_submit
    submit_location != 'ipad'
  end

end
