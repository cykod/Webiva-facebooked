class Facebooked::ConnectRenderer < ParagraphRenderer

  features '/facebooked/connect_feature'

  paragraph :login

  def login
    @options = paragraph_options(:login)

    @logged_in = self.facebook_client.validate_fb_cookies(cookies)
    if @logged_in
      logger.warn( self.facebook_client.session.user.inspect )
    end

    @onlogin = @options.onlogin_redirect_url ? "window.location.href='#{@onlogin.onlogin_redirect_url}'" : 'window.location.reload(true);'

    render_paragraph :feature => :facebooked_connect_login
  end


  protected

  def facebook_client
    @facebook_client ||= Facebooked::AdminController.facebook_client
  end
end
