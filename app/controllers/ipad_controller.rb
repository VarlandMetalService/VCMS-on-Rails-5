class IpadController < ApplicationController
  def index
  end

  def new
    @ipad_user = User.find(session[:ipad_user_id])
    if(@ipad_user.pin != params[:pin])
      # TODO: Diplay error message, incorrect pin
      redirect_to action: 'enter_pin'
    end
  end

  def update
    @employee = User.find_by_employee_number(params[:user_view])
    # WARNING: update_attributes bypasses model validations
      # TODO: ensure that the param value meets the validation requirements
    if @employee.update_attribute(:pin, params[:pin])
      redirect_to 'enter_pin'
    else
      # TODO: Display error message, invalid value
      render 'change_pin'
    end
  end

  def enter_pin
    session[:ipad_user_id] = User.find_by_employee_number(params[:employee_number]).id
    @ipad_user = User.find(session[:ipad_user_id])
  end

  def change_pin
    @ipad_user = User.find(session[:ipad_user_id])
  end

  def logout
    session.delete(:ipad_user_id)
    redirect_to action: 'index'
  end

end
