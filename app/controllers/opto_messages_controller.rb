class OptoMessagesController < ApplicationController
  before_action :check_permission

  has_scope :search_query
  has_scope :with_date_gte
  has_scope :with_date_lte
  has_scope :sorted_by
  has_scope :with_department
  has_scope :with_lane
  has_scope :with_station
  has_scope :with_barrel
  has_scope :with_shop_order
  has_scope :with_load
  has_scope :with_type
  has_scope :without_type

  def index
    @opto_messages = apply_scopes(OptoMessage).all.page(params[:page])

    respond_to do |format|
      format.js
      format.html
    end
  end

private

  def check_permission
    require_permission 'opto_messages', 3
  end

end
