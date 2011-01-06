class Facebooked::ConnectRenderer < ParagraphRenderer

  features '/facebooked/connect_feature'

  paragraph :request_form
  paragraph :publish

  def request_form
    @options = paragraph_options(:request_form)

    @provider = Facebooked::OauthProvider.new session
    @logged_in = @provider.logged_in?

    render_paragraph :feature => :facebooked_connect_request_form
  end

  def publish
    @options = paragraph_options(:publish)

    @provider = Facebooked::OauthProvider.new session
    @logged_in = @provider.logged_in?

    @post = @options.post
    if request.post? && params[:post]
      @post.message = params[:post][:message] if params[:post][:message]
      if @post.valid? && @post.publish(@provider)
        @published = true
        return redirect_paragraph @options.success_page_url if @options.success_page_url
      end
    end

    render_paragraph :feature => :facebooked_connect_publish
  end
end
