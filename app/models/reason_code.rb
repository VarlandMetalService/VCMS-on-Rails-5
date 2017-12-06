class ReasonCode < ApplicationRecord

  has_many :timeclock_records

  default_scope { where 'is_deleted IS FALSE'}

  def self.options_for_code
    ReasonCode.all.where('is_deleted IS FALSE').order(code: :asc)
  end

end
