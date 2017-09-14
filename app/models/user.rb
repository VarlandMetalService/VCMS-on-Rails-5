require 'net/http'

class User < ApplicationRecord

  # Constants.
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  # Pagination.
  self.per_page = 50

  # Associations.
  has_many      :assigned_permissions
  has_many      :permissions,
                -> { select('permissions.*,
                            assigned_permissions.value AS access_level') },
                :through => :assigned_permissions

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
      uri = 'http://api.varland.com/v1/auth?user=' + self.username + '&password=' + password
      response = Net::HTTP.get(uri)

      response == '1' ? true : false
    rescue => e
      false
    end
  end

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data['email']).first_name
    user
  end

  # Shortcut method for returning user's full name.
  def full_name
    if suffix.blank?
      "#{first_name} #{last_name}"
    else
      "#{first_name} #{last_name} #{suffix}"
    end
  end

  # Returns select options for employees.
  def self.options_for_select
    order('employee_number').map { |u| ["#{u.employee_number} - #{u.full_name}", u.id] }
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
