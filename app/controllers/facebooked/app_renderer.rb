
class Facebooked::AppRenderer < ParagraphRenderer

  features '/facebooked/app_feature'

  paragraph :login

  def login
    return render_paragraph :text => 'Facebook Application Login' if editor?

    # rendering a facebook tab
    return render_paragraph(:nothing => true) if self.controller.is_a?(Facebooked::TabController)

    if self.logged_in?
      return render_paragraph(:nothing => true) unless session[:lock_lockout]

      lock_lockout = session[:lock_lockout]
      session[:lock_lockout] = nil
      return render_paragraph(:nothing => true) if self.lock_lockout_url == lock_lockout

      return redirect_paragraph lock_lockout
    end

    session[:lock_lockout] = self.lock_lockout_url
    data_paragraph :type => 'text/html', :text => login_html
  end

  protected

  def logged_in?
    if params[:signed_request]
      # make sure the signed_request user and the user logged in with oauth are the same user
      signed_request = Facebooked::SignedRequest.new params[:signed_request]
      return false unless signed_request.valid? && signed_request.user_id && self.provider.logged_in? && self.provider.provider_id && signed_request.user_id == self.provider.provider_id
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

  # removes the signed_request from the url
  def lock_lockout_url
    url = request.request_uri
    url, query = url.split '?'
    query = query.split('&').map { |p| p.match(/^signed_request=/) ? nil : p }.compact.join('&') unless query.blank?
    url = "#{url}?#{query}" unless query.blank?
    url
  end
end
