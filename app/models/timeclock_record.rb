class TimeclockRecord < ApplicationRecord
  belongs_to :user
  belongs_to :reason_code, optional: true

  before_validation :check_datetime_format
  before_save :check_for_buffer

  validates :user,
            presence: true
  validates :record_type,
            presence: true
  validates :record_timestamp,
            presence: true

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
    errors.add(:record_timestamp, 'must be a valid date/time') if ((DateTime.parse(record_timestamp) rescue ArgumentError) == ArgumentError)
    throw :abort if !record_timestamp
  end

  def check_for_buffer
    buffer = 10.seconds
    buffer_min = [1, 16, 31, 46]
    record_timestamp -= buffer if record_timestamp.sec <= buffer && buffer_min.include?(record_timestamp.min)
  end

end
