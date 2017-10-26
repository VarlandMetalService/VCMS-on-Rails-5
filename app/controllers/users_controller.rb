class UsersController < ApplicationController

  before_action :set_user, only: [:edit, :update]
  before_action :check_permission
  before_action :create_timeclock_record, only: [:update], if: "params[:user][:ipad_submit] && params[:user][:current_status]"

  def index
    @users = User.all.page(params[:page]).order(:employee_number)
  end

  def edit
  end

  def update
    if @user.update user_params
      if params[:user][:ipad_submit]
        if params[:user][:current_status]
          session.delete(:ipad_user)
          flash[:success] = params[:user][:success_message]
          redirect_to controller: 'ipad', action: 'index' and return
        end
        flash[:success] = params[:user][:success_message]
        redirect_to controller: 'ipad', action: 'employee_action', pin: @user.pin and return
      end
      redirect_to users_url, notice: "Successfully updated <code>#{@user.full_name}</code>."
    else
      if params[:user][:ipad_submit]
        if params[:user][:current_status]
          flash[:error] = params[:user][:failure_message]
          redirect_to controller: 'ipad', action: 'employee_action', pin: @user.pin, error: true and return
        end
        flash[:error] = params[:user][:failure_message]
        redirect_to controller: 'ipad', action: 'change_pin' and return
      end
      render :edit
    end
  end

private

  def set_user
    @user = User.find params[:id]
  end

  def check_permission
    require_permission 'sysadmin', 3
  end

  def user_params
    params.require(:user).permit(:username, :employee_number, :first_name, :last_name, :suffix, :initials, :email, :pin, :current_status,
                                 :background_color, :text_color, :is_active, timeclock_records_attributes: [:id, :record_type,
                                 :record_timestamp, :submit_type, :ip_address])
  end

  def create_timeclock_record
    timeclock_record = TimeclockRecord.new
    timeclock_record.user_id = @user.id
    timeclock_record.record_type = params[:user][:record_type]
    timeclock_record.record_timestamp = params[:user][:record_timestamp]
    timeclock_record.submit_type = params[:user][:submit_type]
    timeclock_record.ip_address = params[:user][:ip_address]
    if !timeclock_record.save
      puts "Yup it happened, timeclock record did not save: #{timeclock_record.errors.full_messages[0]}"
      redirect_to controller: 'ipad', action: 'employee_action', pin: @user.pin, error: true and return
    end
  end

end