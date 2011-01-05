
class Facebooked::AppRenderer < ParagraphRenderer

  features '/facebooked/app_feature'

  paragraph :login

  def login
    return render_paragraph :text => 'Facebook Application Login' if editor?
    return render_paragraph :nothing => true if self.provider.logged_in?

    data_paragraph :type => 'text/html', :text => login_html
  end

  protected

  def provider
    @provider ||= Facebooked::OauthProvider.new session
  end

  def login_html
    <<-LOGIN
<html>
<head>
<script type="text/javascript">
window.location = "#{url_for :controller => '/facebooked/client', :action => 'login', :provider => 'facebook'}";
</script>
</head>
</html>
    LOGIN
  end
end
