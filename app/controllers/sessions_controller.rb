class SessionsController < ApplicationController


  before_filter :already_signed_in, only: [:new, :create]

  def new
    #get
  end

  def create
    #post
    user = User.find_by_email(params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      sign_in user
      redirect_back_or user
    else
      flash.now[:error] = 'Invalid email/password combination'
      render 'new'
    end
  end#create

  def destroy
    sign_out
    redirect_to root_url
  end

  private
    def already_signed_in
      unless !signed_in?
        redirect_to root_path
      end
    end
  #private
end
