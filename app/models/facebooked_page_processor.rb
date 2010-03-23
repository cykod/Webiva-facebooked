
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

    xd_receiver_url = '/components/facebooked/xd_receiver.htm'

    output.html_set_attribute(:html_tag, {'xmlns:fb' => 'http://www.facebook.com/2008/fbml'})
    output.includes[:js] ||= []
    output.includes[:js] << '/components/facebooked/javascripts/facebook.js'
    output.includes[:body_start] ||= ''
    permissions = options.email_permission == 'required' ? "'email'" : 'null'
    logged_in = @controller.session[:facebook_logged_in] ? 'true' : 'false'
    output.includes[:body_start] << "<script type='text/javascript'>Facebooked.setup('#{options.feature_loader_url}', '#{options.api_key}', '#{xd_receiver_url}', #{permissions}, #{logged_in});</script>\n";
  end
end
