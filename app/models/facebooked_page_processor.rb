
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

    xd_receiver_url = Configuration.domain_link '/components/facebooked/xd_receiver.htm'

    output.html_set_attribute(:html_tag, {'xmlns:fb' => 'http://www.facebook.com/2008/fbml'})
    output.includes[:body_start] ||= ''
    output.includes[:body_start] << "<script src='#{options.feature_loader_url}' type='text/javascript'></script>\n<script type='text/javascript'>FB.init('#{options.api_key}', '#{xd_receiver_url}');</script>\n";
  end
end
