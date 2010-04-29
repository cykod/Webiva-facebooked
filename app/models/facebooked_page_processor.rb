
class FacebookedPageProcessor
  def self.page_post_process_handler_info
    {
      :name => 'Facebook Post Processor'
    }
  end

  def initialize(controller)
    @controller = controller
  end

  def post_process(output)
    options = Facebooked::AdminController.module_options
    return if options.api_key.blank?

    output.html_set_attribute(:html_tag, {'xmlns:fb' => 'http://www.facebook.com/2008/fbml'})

    output.includes[:body_end] ||= ''
    permissions = options.email_permission == 'required' ? "'email'" : 'null'

    logged_in = @controller.session[:facebook_logged_in] ? 'true' : 'false'

    body_end = <<-HTML
<div id="fb-root"></div>
<script>
  window.fbAsyncInit = function() {
    FB.init({
      appId  : '#{options.api_key}',
      status : true,
      cookie : true,
      xfbml  : true
    });
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
end
