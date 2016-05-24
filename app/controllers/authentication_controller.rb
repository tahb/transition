class AuthenticationController < ApplicationController
  # we don't need to authenticate these requests, they create the authentication
  skip_before_filter :set_current_user!

  def index
    render layout: nil
  end

  def new
    logger.info('OAuth Initiating to ZenDesk')
    redirect_to '/auth/zendesk'
  end

  def create
    logger.info('OAuth Response Received')
    data = request.env['omniauth.auth']

    sign_in(data['uid'], data['info'])
    redirect_to organisations_path
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end

  private def sign_in(uid, info)
    check_email!(info['email'])

    user = User.find_or_create_by(uid: uid)
    user.update!(name: info['name'], email: info['email'], permissions: ['admin', 'GDS Editor'], organisation_content_id: nil)
    session[:user_id] = user.id
  end

  private def check_email!(email)
    unless email.include? "dxw.com"
      raise "Invalud Email Domain. Forbidden"
    end
  end
end
