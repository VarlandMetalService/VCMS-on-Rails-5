class SessionsController < ApplicationController

  skip_before_action :require_login, :only => [:create, :new]

  def new
    render :layout => false
  end

  def create
    # TODO: decide if we are only using Google auth, or if we are keeping both auth options
    # MAINTENANCE TODO: abstract this logic out to its own method for legibility
    if params[:provider] == 'google_oauth2'
      user = User.from_omniauth(request.env["omniauth.auth"])
      if user && user.is_active
        log_in user
        redirect_to(session[:return_to] || root_path) and return
      else
        flash.now[:error] = 'Authentication failed.'
        render 'new', :layout => false
      end
    elsif params[:session][:login_method] == 'mobile'
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