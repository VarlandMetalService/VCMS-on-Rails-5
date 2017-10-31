class TimeclockRecord < ApplicationRecord
  belongs_to :user
  belongs_to :reason_code, optional: true

  before_validation :check_datetime_format
  before_save :check_timestamp_buffer

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
      ['Hide Notes', '2'],
    ]
  end

private

  def check_timestamp_buffer
    throw :abort if !self.record_timestamp
    buffer = 10.seconds
    buffer_min = [1, 16, 31, 46]
    self.record_timestamp -= buffer if self.record_timestamp.sec <= buffer && buffer_min.include?(self.record_timestamp.min)
  end

  def check_datetime_format
    # Time.zone.parse(record_timestamp.to_s) rescue
    puts "TIMEZONE PARSE: #{Time.zone.parse(record_timestamp)}"
    errors.add(:record_timestamp, 'must be a valid date/time')
  end

end
