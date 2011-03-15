
class Facebooked::AppRenderer < ParagraphRenderer

  features '/facebooked/app_feature'

  paragraph :login

  def login
    return render_paragraph :text => 'Facebook Application Login' if editor?

    # rendering a facebook tab
    return render_paragraph(:nothing => true) if self.controller.is_a?(Facebooked::TabController)

    return render_paragraph(:nothing => true) if self.logged_in?

    session[:lock_lockout] = self.lock_lockout_url
    data_paragraph :type => 'text/html', :text => login_html
  end

  protected

  def logged_in?
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

  # removes the signed_request from the url
  def lock_lockout_url
    url = request.request_uri
    url, query = url.split '?'
    query = query.split('&').map { |p| p.match(/^signed_request=/) ? nil : p }.compact.join('&') unless query.blank?
    url = "#{url}?#{query}" unless query.blank?
    url
  end
end
