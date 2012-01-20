class PublicController < ApplicationController

  def index
    @history = History.public
  end

  def signup
    session[:user] = nil
  end

  def register
    user = User.create(params[:user])
    if user.save
      # nekodovat heslo?
      user.password = Digest::SHA1.hexdigest(user.password)
      user.save
      Mailer.deliver_registration(user)

      #session[:usercode] = user.code
      User.confirm(user.code)

      session[:user] = user.id.to_s
      #session[:user] = user.id.to_s
      #History.add user, nil, 'login.first', {}

      ##params[:usercode] = user.code
      ## really new part
      ## uz se provadi v beforeCreate validaci ... code = user.makecode
      ##user =
      ##    User.confirm(user.code)
      ##session[:user] = user.id.to_s


      redirect_to :controller => 'public', :action => 'registered'
    else
      flash[:reg_user] = user
      redirect_to :controller => 'public', :action => 'signup'
    end
  end

  def registered
  end

  def confirm
    # Confirm user

    user = User.confirm(params[:id])
    #user = User.confirm(session[:usercode])
    # Check whether user was found   
    return redirect_to(:controller => 'public', :action => 'index') if not user
    # Log user in
    session[:user] = user.id.to_s
    History.add user, nil, 'login.first', {}
    redirect_to :controller => 'profile', :action => 'report'
  end

  def login

    # new part naive
    #@user.makecode
    #user = User.confirm(@user.code)
    #session[:user] = user.id.to_s
    #History.add user, nil, 'login.first', {}


    @user = User.authenticate(params[:username], params[:password])
    if @user
      session[:user] = @user.id.to_s
      if params[:remember]
        cookies[:remember_me] = { :value => @user.makecode, :expires => 30.days.from_now }
      else
        cookies[:remember_me] = { :value => @user.makecode }
      end
      History.add @user, nil, 'login.login', {}
      redirect_to :controller => 'profile', :action => 'report'
    else
      session[:user] = nil
      flash[:loginFailed] = true
      redirect_to :controller => 'public'
    end
  end

  def logout
    session[:user] = nil
    cookies[:remember_me] = nil
    if @user
      @user.makecode
    end
    redirect_to :controller => 'public'
  end

end
