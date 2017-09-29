class OptoMessage < ApplicationRecord

  # Default scoping.
  default_scope { order(message_at: :desc) }

  # Pagination.
  self.per_page = 50

  # Scopes.
  scope :sorted_by, ->(sort_option) {
    reorder sort_option
  }
  scope :search_query, ->(query) {
    where 'message like ?', "%#{query}%"
  }
  scope :with_date_gte, ->(value) {
    timestamp = Time.zone.parse(value)
    where 'message_at >= ?', timestamp.utc
  }
  scope :with_date_lte, ->(value) {
    timestamp = Time.zone.parse(value)
    where 'message_at <= ?', timestamp.utc
  }
  scope :with_department, ->(values) {
    where department: [*values]
  }
  scope :with_shop_order, ->(values) {
    where shop_order: [*values]
  }
  scope :with_load, ->(values) {
    where load: [*values]
  }
  scope :with_lane, ->(values) {
    where lane: [*values]
  }
  scope :with_station, ->(values) {
    where station: [*values]
  }
  scope :with_barrel, ->(values) {
    where barrel: [*values]
  }
  scope :with_type, ->(values) {
    return if values == [""]
    where message_name: [*values]
  }
  scope :without_type, ->(values) {
    return if values == [""]
    where.not message_name: [*values]
  }

  def self.options_for_department
    [
      ['Dept. 3', '3'],
      ['Dept. 4', '4'],
      ['Dept. 5', '5'],
      ['Dept. 6', '6'],
      ['Dept. 7', '7'],
      ['Dept. 8', '8'],
      ['Dept. 10', '10'],
      ['Dept. 12', '12'],
      ['Waste Water', '30']
    ]
  end

  def self.options_for_sorted_by
    [
      ['Date (newest first)', 'message_at DESC'],
      ['Date (oldest first)', 'message_at']
    ]
  end

  def self.options_for_type
    OptoMessage.distinct.pluck(:message_name).sort
  end

  def self.options_for_barrel
    barrels = OptoMessage.distinct.pluck(:barrel)
    barrels.compact!
    barrels.sort!
  end

  def self.options_for_lane
    lanes = OptoMessage.distinct.pluck(:lane)
    lanes.compact!
    lanes.sort!
  end

end
