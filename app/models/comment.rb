class Comment < ApplicationRecord
  before_validation do
    self.destroy if self.content && self.content.empty?
  end

  belongs_to :commentable, polymorphic: true
  has_many   :attachments,
             as: :attachable,
             dependent: :destroy

  accepts_nested_attributes_for   :attachments,
                                  reject_if: :all_blank,
                                  allow_destroy: true
end
