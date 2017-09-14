class SessionsController < ApplicationController

  skip_before_action :require_login, :only => [:create, :new]

  def new
    render :layout => false
  end

  def create
    if params[:session][:login_method] == 'mobile'
      # user = User.from_omniauth(request.env["omniauth.auth"])
      user = User.find_by(employee_number: params[:session][:employee_number])
      if user && user.pin == params[:session][:pin] && user.is_active
        log_in user
        redirect_to(session[:return_to] || root_path) and return
      else
        flash.now[:error] = 'Authentication failed.'
        render 'new', :layout => false
      end
    else
      user = User.find_by(username: params[:session][:username].downcase)
      if user.nil?
        user = User.find_by(email: params[:session][:username].downcase)
      end
      if user && user.authenticate(params[:session][:password]) && user.is_active
        log_in user
        redirect_to(session[:return_to] || root_path) and return
      else
        flash.now[:error] = 'Authentication failed. Please try again or contact IT for help. Make sure you are using your System i username and password, not your email username and password.'
        render 'new', :layout => false
      end
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end

end