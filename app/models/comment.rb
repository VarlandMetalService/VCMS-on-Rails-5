class Comment < ApplicationRecord
  before_validation do
    self.destroy if self.content && self.content.empty?
  end

  belongs_to :commentable, polymorphic: true
end
