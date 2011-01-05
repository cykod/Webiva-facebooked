
class Facebooked::AppRenderer < ParagraphRenderer

  features '/facebooked/app_feature'

  paragraph :login

  def login
    return render_paragraph :text => 'Facebook Application Login' if editor?
    return render_paragraph :nothing => true if self.logged_in?
    data_paragraph :type => 'text/html', :text => login_html
  end

  protected

  def logged_in?
    if params[:signed_request]
      signed_request = Facebooked::SignedRequest.new params[:signed_request]
      if ! signed_request.valid? || signed_request.user_id.nil? || self.provider.provider_id.nil? || signed_request.user_id != self.provider.provider_id
        self.process_logout
        return false
      end
    end

    self.provider.logged_in?
  end

  def provider
    @provider ||= Facebooked::OauthProvider.new session
  end

  def login_html
    <<-LOGIN
<html>
<head>
<script type="text/javascript">
top.location = "#{url_for :controller => '/facebooked/client', :action => 'login'}";
</script>
</head>
</html>
    LOGIN
  end
end
