class UsersController < ApplicationController
  before_action :check_permission
  before_action :set_user, only: [:edit, :update]

  def index
    @users = User.all.page(params[:page]).order(:employee_number)
  end

  def edit
  end

  def update
    if @user.update user_params
      if params[:user][:ipad_submit] # Successful change pin request
        flash[:success] = params[:user][:success_message]
        redirect_to controller: 'ipad', action: 'employee_action', pin: @user.pin and return
      end
      redirect_to users_url, notice: "Successfully updated <code>#{@user.full_name}</code>."
    else
      if params[:user][:ipad_submit] # Failed change pin request
        flash[:error] = params[:user][:failure_message]
        redirect_to controller: 'ipad', action: 'change_pin' and return
      end
      render :edit
    end
  end

private

  def check_permission
    require_permission 'sysadmin', 3
  end

  def set_user
    @user = User.find params[:id]
  end

  def user_params
    params.require(:user).permit(:username, :employee_number, :first_name, :last_name, :suffix, :initials,
                                 :email, :pin, :current_status, :background_color, :text_color, :is_active,
                                 timeclock_records_attributes: [:id, :record_type, :record_timestamp, :submit_type, :ip_address])
  end

end