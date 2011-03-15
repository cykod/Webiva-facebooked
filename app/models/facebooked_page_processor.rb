
class FacebookedPageProcessor
  def self.page_post_process_handler_info
    {
      :name => 'Facebook Post Processor'
    }
  end

  def self.page_before_request_handler_info
    {
      :name => 'Facebook Before Request Processor'
    }
  end

  def initialize(controller)
    @controller = controller
  end

  def post_process(output)
    options = Facebooked::AdminController.module_options
    return if options.app_id.blank?

    output.html_set_attribute(:html_tag, {'xmlns:fb' => 'http://www.facebook.com/2008/fbml'})

    output.includes[:body_end] ||= ''
    permissions = options.email_permission == 'required' ? "'email'" : 'null'

    logged_in = @controller.session[:facebook_logged_in] ? 'true' : 'false'

    body_end = <<-HTML
<div id="fb-root"></div>
<script>
  window.fbAsyncInit = function() {
    FB.init({
      appId: '#{options.app_id}',
      status: true,
      cookie: true,
      xfbml: true,
      channelUrl: '#{Configuration.domain_link "/components/facebooked/channel.html"}'
    });
    #{'FB.Canvas.setSize();' if DomainModel.active_domain_id.to_i == Facebooked::AdminController.module_options.facebook_domain_id}
  };

  (function() {
    var e = document.createElement('script');
    e.src = document.location.protocol + '//connect.facebook.net/en_US/all.js';
    e.async = true;
    document.getElementById('fb-root').appendChild(e);
  }());
</script>
    HTML

    output.includes[:body_end] << body_end
  end
  
  def before_request
    return true unless @controller.request.post?
    return true unless @controller.params[:signed_request]
    
    if self.logged_in?(@controller.params)
      lock_lockout = @controller.session[:lock_lockout] || self.lock_lockout_url
      @controller.session[:lock_lockout] = nil
      @controller.send(:redirect_to, lock_lockout)
    else
      @controller.send(:render, :text => self.login_html)
    end

    false
  end

  def logged_in?(params)
    # make sure the signed_request user and the user logged in with oauth are the same user
    signed_request = Facebooked::SignedRequest.new params[:signed_request]
    return false unless signed_request.valid? && signed_request.user_id && self.provider.logged_in? && self.provider.provider_id && signed_request.user_id == self.provider.provider_id
    self.provider.logged_in?
  end

  def provider
    @provider ||= Facebooked::OauthProvider.new @controller.session
  end

  def login_html
    <<-LOGIN
<html>
<head>
<script type="text/javascript">
top.location = "#{@controller.url_for :controller => '/facebooked/client', :action => 'login'}";
</script>
</head>
</html>
    LOGIN
  end

  # removes the signed_request from the url
  def lock_lockout_url
    url = @controller.request.request_uri
    url, query = url.split '?'
    query = query.split('&').map { |p| p.match(/^signed_request=/) ? nil : p }.compact.join('&') unless query.blank?
    url = "#{url}?#{query}" unless query.blank?
    url
  end
end
