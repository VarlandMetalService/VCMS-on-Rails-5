class Attachment < ApplicationRecord

  # CarrierWave uploader support.
  mount_uploader  :file,
  FileUploader

  # Associations.
  belongs_to      :attachable,
                  polymorphic: true,
                  optional: true

  accepts_nested_attributes_for   :attachable,
                                  reject_if: :all_blank

end
