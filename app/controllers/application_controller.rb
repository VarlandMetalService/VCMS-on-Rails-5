class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :require_login

  include SessionsHelper

protected

  def check_permission(right)
    if current_user.nil?
      @access_level = nil
    else
      @access_level ||= current_user.permissions.find_by_permission right
    end
  end

  def require_permission(right, level)
    @access_level ||= current_user.permissions.find_by_permission right
    if @access_level.nil? || @access_level.access_level < level
      redirect_to(root_url, flash: { error: 'Permission denied. Please contact IT if you have questions.' }) and return
    end
  end

  def require_login
    unless logged_in?
      session[:return_to] = request.fullpath
      redirect_to(login_url) and return
    end
    session.delete(:return_to)
  end

  def my_logger
    @@my_logger ||= Logger.new("#{Rails.root}/log/my_dev.log")
  end

end
