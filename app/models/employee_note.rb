class EmployeeNote < ApplicationRecord

  # Constants.
  VALID_IP_REGEX = /\A([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}\z/i

  # Default scoping.
  default_scope { order(note_on: :desc) }

  # Pagination.
  self.per_page = 50

  # Associations.
  belongs_to    :subject,
                class_name: 'User',
                foreign_key: 'employee'
  belongs_to    :author,
                class_name: 'User',
                foreign_key: 'entered_by'

  # Validations.
  validates :subject,
            presence: true
  validates :entered_by,
            presence: true
  validates :note_on,
            presence: true
  validates :note_type,
            presence: true,
            inclusion: { in: %w(Positive Negative Neutral), message: "%{value} is not a valid type" }
  validates :ip_address,
            presence: true,
            format: { with: VALID_IP_REGEX }
  validates :notes,
            presence: true

  # Scopes.
  scope :sorted_by, ->(sort_option) {
    reorder sort_option
  }
  scope :search_query, ->(query) {
    where 'notes like ? or follow_up like ?', "%#{query}%", "%#{query}%"
  }
  scope :with_employee, ->(values) {
    where employee: [*values]
  }
  scope :with_note_type, ->(values) {
    where note_type: [*values]
  }
  scope :with_entered_by, ->(values) {
    where entered_by: [*values]
  }
  scope :with_date_gte, ->(value) {
    begin
      date = Date.strptime(value, '%m/%d/%Y')
      where 'note_on >= ?', date.strftime('%Y-%m-%d')
    rescue
      return
    end
  }
  scope :with_date_lte, ->(value) {
    begin
      date = Date.strptime(value, '%m/%d/%Y')
      where 'note_on <= ?', date.strftime('%Y-%m-%d')
    rescue
      return
    end
  }

  def self.options_for_type
    [
      ['Positive', 'Positive'],
      ['Negative', 'Negative'],
      ['Neutral', 'Neutral']
    ]
  end

  def self.options_for_sorted_by
    [
      ['Date (newest first)', 'note_on DESC'],
      ['Date (oldest first)', 'note_on']
    ]
  end

  def self.options_for_entered_by
    users = User.where id: EmployeeNote.all.distinct.pluck(:entered_by)
    users.map { |u| [u.full_name, u.id] }
  end

  def initialize(params = {})
    super
    current_time = Time.new
    today = Date.today
    case current_time.hour
      when 0..6
        self.note_on = today - 1
      when 7..23
        self.note_on = today
    end
  end

end
