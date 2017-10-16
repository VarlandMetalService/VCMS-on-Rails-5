require 'rest-client'

class User < ApplicationRecord

  # Constants.
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  # Pagination.
  self.per_page = 50

  # Associations.
  has_many      :documents,
                foreign_key: 'added_by'
  has_many      :employee_notes,
                class_name: 'EmployeeNote',
                foreign_key: 'employee'
  has_many      :authored_employee_notes,
                -> { order 'note_on DESC' },
                class_name: 'EmployeeNote',
                foreign_key: 'entered_by'
  has_many      :assigned_permissions
  has_many      :permissions,
                -> { select('permissions.*,
                            assigned_permissions.value AS access_level') },
                :through => :assigned_permissions
  has_many      :shift_notes,
                foreign_key: 'entered_by'
  has_many      :salt_spray_tests,
                foreign_key: 'put_on_by'

  accepts_nested_attributes_for   :assigned_permissions,
                                  reject_if: :all_blank,
                                  allow_destroy: true
  accepts_nested_attributes_for   :permissions

  # Filters.
  before_save { self.email = email.downcase }
  before_save { self.username = username.downcase }

  # Validations.
  validates :username,
    presence: true,
    length: { maximum: 10 },
    uniqueness: { case_sensitive: false }
  validates :employee_number,
    presence: true,
    uniqueness: { case_sensitive: false }
  validates :first_name,
    presence: true,
    length: { maximum: 25 }
  validates :last_name,
    presence: true,
    length: { maximum: 25 }
  validates :initials,
    presence: true,
    length: { maximum: 5 }
  validates :email,
    presence: true,
    length: { maximum: 255 },
    format: { with: VALID_EMAIL_REGEX },
    uniqueness: { case_sensitive: false }

  # Uses Net::HTTP to authenticate user on IBM System i.
  def authenticate(password = '')
    begin
      response = RestClient.get 'http://api.varland.com/v1/auth', params: { user: self.username,
                                                                            password: password }

      response == '1' ? true : false
    rescue => e
      logger.debug("ERROR (User Model - authenticate): #{e.message}")
      false
    end
  end

  def self.from_omniauth(access_token)
    begin
      data = access_token.info
      if access_token.extra.raw_info['hd'] == 'varland.com'
        user = User.where(email: data['email']).first
        return user
      end
      false
    rescue => e
      puts e.message
      false
    end
  end

  def self.options_for_employees
    order('employee_number').map { |u| ["#{u.employee_number} - #{u.full_name}", u.id] }
  end

  def full_name
    if suffix.blank?
      "#{first_name} #{last_name}"
    else
      "#{first_name} #{last_name} #{suffix}"
    end
  end

  def number_and_name
    "#{employee_number} - #{full_name}"
  end

  def is_sysadmin
    @access_level ||= permissions.find_by_permission 'sysadmin'
    if @access_level.nil? || @access_level.access_level < 3
      false
    else
      true
    end
  end

  def update_status
    # Find last clock record for user.
    last_record = TimeclockRecord.where('user_id = ? AND is_deleted IS FALSE', self.id).order(timestamp: :desc).first

    if !last_record
      self.current_status = 'out'
      self.status_timestamp = nil
      self.save
      return
    end

    # If last record was notes record, find previous record.
    invalid_ids = []
    while last_record.record_type == 'Notes'
      invalid_ids << last_record.id
      last_record = TimeclockRecord.where('user_id = ? AND is_deleted IS FALSE AND id NOT IN (?)', self.id, invalid_ids).order(timestamp: :desc).first

      if last_record.nil?
        self.current_status = 'out'
        self.status_timestamp = nil
        self.save
        return
      end
    end

    last_in = TimeclockRecord.where('user_id = ? AND record_type = ? AND is_deleted IS FALSE', self.id, 'Start Work').order(record_timestamp: :desc)

    # If last record was clock out or in, update status.
    case last_record.record_type
    when 'Start Work'
      self.current_status = 'in'
      self.status_timestamp = last_record.record_timestamp
      self.save
      return
    when 'End Work'
      self.current_status = 'out'
      self.status_timestamp = nil
      self.save
      return
    when 'Start Break'
      self.current_status = 'break'
      self.status_timestamp = last_in.record_timestamp
      self.save
      return
    when 'End Break'
      self.current_status = 'in'
      self.status_timestamp = last_in.record_timestamp
      self.save
      return
    end

  end

  def punch_clock(record_type, submit_type = 'pin', timestamp = DateTime.current)

    day = timestamp.strftime('%e')
    hour = timestamp.strftime('%k')
    minute = timestamp.strftime('%M')
    second = timestamp.strftime('%S')

    # is_first_of_month = (day == 1)

    # NOTE: check_labor_entry makes a call to System i which requires PHP, therefore
    #       we will need to add this to the API
    # if record_type == 'End Work'
      # labor_entered = self.check_labor_entry(timestamp)
      # if !labor_entered && !is_first_of_month
        # return false
      # end
    # end

    # if clocking in within the buffer time on a 15 min border, subtract the buffer time.
    buffer = 10
    if record_type == 'Start Work'
      if second <= buffer && (minute == 1 || minute == 16 || minute == 31 || minute == 46)
        timestamp -= buffer
      end
    end

    # Create new clock record
    clock_record = new TimeclockRecord
    clock_record.user_id = self.id
    clock_record.record_type = record_type
    clock_record.submit_type = submit_type
    clock_record.record_timestamp = timestamp.strftime('%F')
    if !clock_record.save
      return false
    end

    case record_type
    when 'Start Work'
      self.current_status = 'in'
      self.status_timestamp = timestamp.strftime('%F')
      return self.save
    when 'End Work'
      self.current_status = 'out'
      self.status_timestamp = nil
      return self.save
    when 'Start Break'
      self.current_status = 'in'
      self.status_timestamp = timestamp.strftime('%F')
      return self.save
    when 'End Break'
      self.current_status = 'in'
      self.status_timestamp = timestamp.strftime('%F')
      return self.save
    end

  end

end
