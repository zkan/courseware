# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController

  # render new.erb.html
  def new
    @course = params[:course_id] ? Course.find(params[:course_id]) : nil
  end

  def create
    logout_keeping_session!
    user = User.authenticate(params[:login], params[:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_back_or_default( courses_path )
      flash[:notice] = "Logged in successfully"
    else
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      redirect_to login_path
    end
  end

  def destroy
    redirect_page = session[:return_to] || courses_path
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(redirect_page)
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
