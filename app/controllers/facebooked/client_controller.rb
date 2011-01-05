
class Facebooked::ClientController < Oauth::ClientController

  protected

  def provider
    return @provider if @provider
    @provider = Facebooked::OauthProvider.new session
    @provider.redirect_uri = url_for :action => 'callback', :provider => 'facebook', :url => '/'
    @provider
  end

  def return_url
    Facebooked::AdminController.module_options.canvas_url
  end
end
