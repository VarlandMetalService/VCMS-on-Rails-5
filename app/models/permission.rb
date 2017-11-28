class Permission < ApplicationRecord

  before_save :format_values

  self.per_page = 50

  has_many      :assigned_permissions,
                -> { includes(:user).order('users.employee_number ASC') }
  has_many      :users,
                -> { select('users.*, assigned_permissions.value AS access_level') },
                :through => :assigned_permissions

  accepts_nested_attributes_for   :assigned_permissions,
                                  reject_if: :all_blank,
                                  allow_destroy: true
  accepts_nested_attributes_for   :users

  validates :permission,
            presence: true,
            uniqueness: { case_sensitive: false }
  validates :description,
            presence: true

private

  def format_values
    self.permission = permission.downcase
  end

end
