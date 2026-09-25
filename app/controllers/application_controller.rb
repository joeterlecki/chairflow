class ApplicationController < ActionController::Base
  before_action :require_authentication
  before_action :prevent_private_caching
  before_action :set_sentry_context
  helper_method :current_user
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = User.find_by(id: session[:user_id]) if session[:expires_at].to_i > Time.current.to_i
  end

  def require_authentication
    return if current_user
    reset_session
    session[:return_to] = request.fullpath if request.get? && !turbo_frame_request?
    redirect_to login_path
  end

  def prevent_private_caching
    response.headers["Cache-Control"] = "no-store"
  end

  def set_sentry_context
    Sentry.set_user(current_user ? { id: current_user.id, username: current_user.username } : {})
  end
end
