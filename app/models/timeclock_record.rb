class TimeclockRecord < ApplicationRecord
  belongs_to :user
  belongs_to :reason_code, optional: true

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

  def check_timestamp_buffer
    buffer = 10
    buffer_min = [1, 16, 31, 46]
    self.record_timestamp -= buffer if self.record_timestamp.sec <= buffer && buffer_min.include?(self.record_timestamp.min)
  end
end
