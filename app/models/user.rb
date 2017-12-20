require 'rest-client'

class User < ApplicationRecord
  enum role: [:admin, :management, :supervisor, :employee]

  after_initialize :set_default_role, if: :new_record?
  before_save :format_values

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  self.per_page = 50

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
  has_many      :timeclock_records
  has_many      :periods

  accepts_nested_attributes_for   :assigned_permissions,
                                  reject_if: :all_blank,
                                  allow_destroy: true
  accepts_nested_attributes_for   :permissions
  accepts_nested_attributes_for   :timeclock_records,
                                  reject_if: :all_blank,
                                  allow_destroy: true

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
  validates :pin,
    presence: true,
    length: { is: 4 },
    uniqueness: { case_sensitive: false }

  def self.options_for_employees
    order('employee_number').map { |u| ["#{u.employee_number} - #{u.full_name}", u.id] }
  end

  def self.options_for_role
    self.roles
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

  # TODO: Reformat/Replace this method (most of it is already performed elsewhere)
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

  end

private

  def set_default_role
    # self.role ||= :employee
  end

  def format_values
    self.email = email.downcase
    self.username = username.downcase
  end

end
