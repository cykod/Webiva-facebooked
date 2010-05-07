class Facebooked::ConnectFeature < ParagraphFeature

  include FacebookedHelper

  feature :facebooked_connect_request_form, :default_feature => <<-FEATURE
  <cms:logged_in>
    <cms:request_form/>
  </cms:logged_in>
  <cms:not_logged_in>
    Facebook access required, <cms:connect_link>connect with Facebook</cms:connect_link>
  </cms:not_logged_in>
  FEATURE

  def facebooked_connect_request_form_feature(data)
    webiva_feature(:facebooked_connect_request_form,data) do |c|
      c.expansion_tag('logged_in') { |t| t.locals.user = data[:logged_in] }

      c.define_tag('logged_in:request_form') do |t|
        request_form(data[:options].request_form)
      end

      c.link_tag('connect') { |t| url_for(:controller => '/oauth/client', :action => 'login', :provider => 'facebook', :url => site_node.node_path) }
    end
  end

  def fb_connect_form(context, data)
    context.define_tag('connect_form') do |t|
      width = t.attr['width'] || 600
      serverfbml_tag('connect-form', "\n", 'serverfbml' => {'style' => "width:#{width}px;"}, 'action' => Configuration.domain_link('/'))
    end
  end
end
