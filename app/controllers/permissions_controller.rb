class PermissionsController < ApplicationController
  before_action :check_permission
  before_action :set_permission, only: [:edit, :update]

  def index
    @permissions = Permission.order('permission').page(params[:page])
  end

  def edit
  end

  def update
    if @permission.update permission_params
      redirect_to permissions_url, notice: "Successfully updated <code>#{@permission.permission}</code>.".html_safe
    else
      render :edit
    end
  end

private

  def check_permission
    require_permission 'sysadmin', 3
  end

  def set_permission
    @permission = Permission.find params[:id]
  end

  def permission_params
    params.require(:permission).permit(:permission, :description, assigned_permissions_attributes: [:id, :user_id, :value, :_destroy])
  end

end