class UsersController < ApplicationController
  
  before_action :set_user, only: [:edit, :update]
  before_action :check_permission
  
  def index
    @users = User.all.page(params[:page]).order(:employee_number)
  end
  
  def edit
  end
  
  def update
    if @user.update user_params
      redirect_to users_url, notice: "Successfully updated <code>#{@user.full_name}</code>."
    else
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
    params.require(:user).permit(:username, :employee_number, :first_name, :last_name, :suffix, :initials, :email, :pin, :background_color, :text_color, :is_active)
  end 
  
end