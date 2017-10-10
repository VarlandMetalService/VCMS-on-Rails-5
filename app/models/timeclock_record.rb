class TimeclockRecord < ApplicationRecord
  belongs_to :user
  belongs_to :reason_code
end
