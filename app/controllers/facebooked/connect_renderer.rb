class Facebooked::ConnectRenderer < ParagraphRenderer

  features '/facebooked/connect_feature'

  paragraph :request_form

  def request_form
    @options = paragraph_options(:request_form)

    @provider = Facebooked::OauthProvider.new session
    @logged_in = @provider.logged_in?

    render_paragraph :feature => :facebooked_connect_request_form
  end
end
