class Comment < ApplicationRecord
  before_validation :check_for_blank

  belongs_to :commentable, polymorphic: true
  has_many   :attachments,
             as: :attachable,
             dependent: :destroy,
             after_remove: :check_for_blank

  accepts_nested_attributes_for   :attachments,
                                  reject_if: :all_blank,
                                  allow_destroy: true

private

  def check_for_blank(attachment = nil)
    self.destroy if self.content.blank? && self.attachments.size == 0
  end
end
