class AssignedPermission < ApplicationRecord

  # Associations.
  belongs_to      :user
  belongs_to      :permission

  accepts_nested_attributes_for   :permission,
                                  reject_if: :all_blank
  accepts_nested_attributes_for   :user,
                                  reject_if: :all_blank

  # Validations.
  validates :user_id,
            uniqueness: { scope: :permission_id, message: 'cannot be assigned more than once' }

  # Select options for value.
  def self.options_for_value label_set = false
    case label_set
      when 1      # Employee Notes
        [
          ['No Access to Notes', '0'],
          ['Manage Own Notes', '2'],
          ['Manage Everybody\'s Notes', '3']
        ]
      when 2      # Sysadmin
        [
          ['No Admin Access', '0'],
          ['Admin Access', '3']
        ]
      when 3      # QMS
        [
          ['No Access', '0'],
          ['View Only', '1'],
          ['Comment', '2'],
          ['Manage', '3']
        ]
      when 4      # Timeclock
        [
          ['No Access', '0'],
          ['Edit Timeclock Records', '2'],
          ['Timeclock Administrator', '3']
        ]
      when 5      # QMS Management Review
        [
          ['Does Not Participate in Management Review', '0'],
          ['Participates in Management Review', '3']
        ]
      when 6      # Yes/No Access
        [
          ['No Access', '0'],
          ['Access', '3']
        ]
      when 7      # Admin/Non-Admin Access
        [
          ['View Only', '0'],
          ['Admin', '3']
        ]
      else
        [
          ['No Access', '0'],
          ['Read-Only', '1'],
          ['Edit', '2'],
          ['Admin', '3']
        ]
      end
  end

end
