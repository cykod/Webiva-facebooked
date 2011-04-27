
class Facebooked::ClientController < Oauth::ClientController

  skip_before_filter :verify_authenticity_token, :only => ['deauthorize']

  def deauthorize
    signed_request = Facebooked::SignedRequest.new params[:signed_request]
    if signed_request.valid?
      oauth_user = OauthUser.first :conditions => {:provider => 'facebook', :provider_id => signed_request.data['user_id']}
      oauth_user.end_user.unsubscribe if oauth_user && oauth_user.end_user
    end
    render :nothing => true
  end

  protected

  def provider
    return @provider if @provider
    @provider = Facebooked::OauthProvider.new session
    @provider.redirect_uri = url_for :action => 'callback'
    @provider
  end

  def return_url
    Facebooked::AdminController.module_options.canvas_url
  end
end
