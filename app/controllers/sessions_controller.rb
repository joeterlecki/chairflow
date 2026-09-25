class SessionsController < ApplicationController
  skip_before_action :require_authentication, only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> {
    flash.now[:alert] = "Too many sign-in attempts. Please try again in a few minutes."
    render :new, status: :too_many_requests
  }

  def new
    redirect_to root_path if current_user
  end

  def create
    credentials = params.permit(:username, :password)
    if (user = User.authenticate_by(username: credentials[:username].to_s.strip.downcase, password: credentials[:password].to_s))
      destination = session[:return_to]
      reset_session
      session[:user_id] = user.id
      session[:expires_at] = 12.hours.from_now.to_i
      redirect_to destination.presence || root_path, status: :see_other
    else
      flash.now[:alert] = "That username or password wasn’t quite right. Please try again."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "You’ve been signed out. See you soon.", status: :see_other
  end
end
