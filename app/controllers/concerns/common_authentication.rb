# Provides common authentication helper metheods
# Split out of GDS-SSO: https://github.com/alphagov/gds-sso/blob/master/lib/gds-sso/controller_methods.rb
# repurposed to use OmniAuth and ZenDesk
module CommonAuthentication

  class PermissionDeniedException < StandardError
  end

  def self.included(base)
    base.rescue_from PermissionDeniedException do |e|
      render "authorisations/unauthorised", layout: "unauthorised", status: :forbidden, locals: { message: e.message }
    end
    base.helper_method :user_signed_in?
    base.helper_method :current_user
  end


  def authorise_user!(permission)
    # Ensure that we're authenticated (and by extension that current_user is set).
    # Otherwise current_user might be nil, and we'd error out
    authenticate_user!

    if not current_user.has_permission?(permission)
      raise PermissionDeniedException, "Sorry, you don't seem to have the #{permission} permission for this app."
    end
  end

  def require_signin_permission!
    authorise_user!('signin')
  rescue PermissionDeniedException
    render "authorisations/cant_signin", layout: "unauthorised", status: :forbidden
  end

  def authenticate_user!
    warden.authenticate!
  end

  def user_remotely_signed_out?
    warden && warden.authenticated? && warden.user.remotely_signed_out?
  end

  def user_signed_in?
    warden && warden.authenticated? && ! warden.user.remotely_signed_out?
  end

  def current_user
    warden.user if user_signed_in?
  end

  def logout
    warden.logout
  end

  def warden
    request.env['warden']
  end
end

if defined?(ActionController::Base)
  ActionController::Base.extend CommonAuthentication
end
