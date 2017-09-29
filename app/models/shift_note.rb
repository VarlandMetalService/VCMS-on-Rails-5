class ShiftNote < ApplicationRecord

  # Callbacks.
  after_update :send_author_follow_up
  after_create :send_specific_note_email

  # Default scoping.
  default_scope { order(note_on: :desc, shift: :desc, created_at: :desc) }

  # Constants.
  VALID_IP_REGEX = /\A([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}\z/i

  # Pagination.
  self.per_page = 50

  # Associations.
  belongs_to    :author,
                class_name: 'User',
                foreign_key: 'entered_by'
  belongs_to    :supervisor,
                class_name: 'User',
                foreign_key: 'supervisor_id',
                optional: true
  has_many      :attachments,
                as: :attachable,
                dependent: :destroy

  accepts_nested_attributes_for   :attachments,
                                  reject_if: :all_blank,
                                  allow_destroy: true

  # Validations.
  validates :entered_by,
            presence: true
  validates :note_on,
            presence: true
  validates :shift,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 3 }
  validates :ip_address,
            presence: true,
            format: { with: VALID_IP_REGEX }
  validates :department,
            numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 30 },
            allow_nil: true,
            allow_blank: true
  validates :note_type,
            inclusion: { in: %w(Lab Maintenance IT Plating QC Shipping), message: "%{value} is not a valid type" },
            allow_nil: true,
            allow_blank: true
  validates :notes,
            presence: true

  # Scopes.
  scope :sorted_by, ->(sort_option) {
    reorder sort_option
  }
  scope :search_query, ->(query) {
    where 'notes like ?', "%#{query}%"
  }
  scope :with_note_type, ->(values) {
    where note_type: [*values]
  }
  scope :with_entered_by, ->(values) {
    where entered_by: [*values]
  }
  scope :with_date_gte, ->(value) {
    where 'note_on >= ?', value
  }
  scope :with_date_lte, ->(value) {
    where 'note_on <= ?', value
  }
  scope :with_date, ->(value) {
    begin
      date = Date.strptime(value, '%m/%d/%Y')
      where 'note_on = ?', date.strftime('%Y-%m-%d')
    rescue
      return
    end
  }
  scope :with_shift, ->(values) {
    where shift: [*values]
  }
  scope :with_department, ->(values) {
    where department: [*values]
  }

  def store_supervisor_info supervisor
    self.supervisor = supervisor
    self.supervisor_notes_at = Time.new
    self.author_email_needed = true
  end

  def send_author_follow_up
    if self.author_email_needed
      DailyShiftNotesMailer.delay.send_author_supervisor_notes(self.id)
      self.author_email_needed = false
      self.save(validate: false)
    end
  end

  def send_specific_note_email
    case self.note_type
      when 'IT'
        DailyShiftNotesMailer.delay.specific_note_email(self.id, 'it')
      when 'Lab'
        DailyShiftNotesMailer.delay.specific_note_email(self.id, 'lab')
      when 'Maintenance'
        DailyShiftNotesMailer.delay.specific_note_email(self.id, 'maintenance')
      when 'QC'
        DailyShiftNotesMailer.delay.specific_note_email(self.id, 'qc')
      when 'Shipping'
        DailyShiftNotesMailer.delay.specific_note_email(self.id, 'shipping')
      else
        return
    end
  end

  def self.options_for_type
    [
      ['IT', 'IT'],
      ['Lab', 'Lab'],
      ['Maintenance', 'Maintenance'],
      ['Plating', 'Plating'],
      ['QC', 'QC'],
      ['Shipping', 'Shipping']
    ]
  end

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

  def self.options_for_shift
    [
      ['1', '1'],
      ['2', '2'],
      ['3', '3']
    ]
  end

  def self.options_for_sorted_by
    [
      ['Date (newest first)', 'note_on DESC, shift DESC, created_at DESC'],
      ['Date (oldest first)', 'note_on, shift, created_at']
    ]
  end

  def self.options_for_entered_by
    users = User.where id: ShiftNote.distinct.pluck(:entered_by)
    users.map { |u| [u.full_name, u.id] }
  end

  def initialize(params = {})
    super
    current_time = Time.new
    today = Date.today
    case current_time.hour
      when 0..6
        self.shift = 3
        self.note_on = today - 1
      when 7..14
        self.shift = 1
        self.note_on = today
      when 13..22
        self.shift = 2
        self.note_on = today
      when 23
        self.shift = 3
        self.note_on = today
    end
  end

end
