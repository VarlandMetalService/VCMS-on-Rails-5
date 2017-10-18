class IpadController < ApplicationController
  def index
  end

  def new
    @employee = User.find_by_employee_number(params[:employee_number])
  end

  def enter_pin
    @employee = User.find_by_employee_number(params[:employee_number])
  end
end
