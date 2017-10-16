class TimeclockRecord < ApplicationRecord
  belongs_to :user
  belongs_to :reason_code

  def self.options_for_record_type
    [
      ['Start Work', 'Start Work'],
      ['End Work', 'End Work'],
      ['Start Break', 'Start Break'],
      ['End Break', 'End Break'],
      ['Notes', 'Notes']
    ]
  end
end
