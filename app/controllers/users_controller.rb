class UsersController < ApplicationController
  
  # Protect these actions behind an admin login
  require_role 'admin', :for => [:suspend, :unsuspend, :destroy, :purge]

  # Factor out common code across actions
  before_filter :find_user, :only => [:suspend, :unsuspend, :destroy, :purge, :update, :show]
  before_filter :logout, :only => [:create, :activate]

  # Show a form with the user's profile informaiton
  def show
    if !logged_in? or !current_user or !(current_user.has_role?(:admin) or current_user.id == @user.id)
      access_denied
      return
    end
    respond_to do |format|
      format.html { render :action => "edit" }
      format.xml  { render :xml => @user }
    end
  end

  # render new.rhtml
  def new
    @user = User.new
  end
 
  def update
    if !logged_in? or !current_user or !(current_user.has_role? :admin or current_user.id == @user.id)
      access_denied
      return
    end
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(user_path(@user), :notice => 'Profile was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
      
  def create
    @user = User.new(params[:user])
    if @user && @user.valid?
      @user.register!
    end
    logger.debug "Registered user #{@user.inspect} with errors #{@user.errors.inspect}"
    success = @user && @user.valid?
    logger.debug "Validated user #{@user.inspect} with errors #{@user.errors.inspect}"
    if success && @user.errors.empty?
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'new'
    end
  end

  def activate
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to '/login'
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    else 
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default('/')
    end
  end

  def suspend
    @user.suspend! 
    redirect_to users_path
  end

  def unsuspend
    @user.unsuspend! 
    redirect_to users_path
  end

  def destroy
    @user.delete!
    redirect_to users_path
  end

  def purge
    @user.destroy
    redirect_to users_path
  end
  
  protected
  
  def find_user
    @user = User.find(params[:id])
  end
  
  def logout
    logout_keeping_session!
  end
        
end
