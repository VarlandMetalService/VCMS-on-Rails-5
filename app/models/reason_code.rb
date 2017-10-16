class ReasonCode < ApplicationRecord

  has_many :timeclock_records

  def self.options_for_code
    ReasonCode.all.where('is_deleted IS FALSE').order(:code)
  end

end
