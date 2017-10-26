class IpadController < ApplicationController
  def index
  end

  def enter_pin
    redirect_to action: 'index', error: true and return if params[:employee_number].blank?
    session[:ipad_user_id] = User.find_by_employee_number(params[:employee_number]).id
    @ipad_user = User.find(session[:ipad_user_id])
  end

  def employee_action
    @ipad_user = User.find(session[:ipad_user_id])
    if(@ipad_user.pin != params[:pin])
      redirect_to action: 'enter_pin', employee_number: @ipad_user.employee_number, error: true
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
