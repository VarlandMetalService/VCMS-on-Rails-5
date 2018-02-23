class SaltSprayProcessStep < ApplicationRecord
  before_save :check_for_other

  belongs_to :salt_spray_test

  attr_accessor :chromate_other, :top_coat_other

  def self.options_for_chromate
    [
      ['Clear', 'Clear'],
      ['Tri-Yellow', 'Tri-Yellow'],
      ['Tri-Black', 'Tri-Black'],
      ['Dichromate', 'Dichromate'],
      ['Hex-Yellow', 'Hex-Yellow'],
      ['Other', 'Other']
    ]
  end

  def self.options_for_top_coat
    [
      ['250', '250'],
      ['320', '320'],
      ['330', '330'],
      ['437', '437'],
      ['Dipsol', 'Dipsol'],
      ['Wax', 'Wax'],
      ['Other', 'Other']
    ]
  end

private

  def check_for_other
    self.chromate = self.chromate_other if self.chromate_other.present?
    self.top_coat = self.top_coat_other if self.top_coat_other.present?
  end

end
