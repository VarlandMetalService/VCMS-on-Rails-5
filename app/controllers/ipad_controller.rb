class IpadController < ApplicationController

  def index
  end

  def enter_pin
    found_user = User.find_by_employee_number(params[:employee_number])
    if params[:employee_number].blank? || !found_user
      flash[:error] = 'Invalid Employee Number.'
      redirect_to action: 'index' and return
    end
    session[:ipad_user_id] = found_user.id
    @ipad_user = User.find(session[:ipad_user_id])
  end

  def employee_action
    @timeclock_record = TimeclockRecord.new
    @ipad_user = User.find(session[:ipad_user_id])
    if @ipad_user.pin != params[:pin]
      flash[:error] = 'Invalid PIN.'
      redirect_to action: 'enter_pin', employee_number: @ipad_user.employee_number
    end
  end

  def change_pin
    @ipad_user = User.find(session[:ipad_user_id])
  end

  def logout
    session.delete(:ipad_user_id)
    flash[:notice] = 'You have successfully logged out.' unless params[:suppress_notice]
    redirect_to action: 'index'
  end

end
