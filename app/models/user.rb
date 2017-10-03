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

end
