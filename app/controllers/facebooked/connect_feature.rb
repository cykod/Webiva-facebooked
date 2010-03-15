class Facebooked::ConnectFeature < ParagraphFeature

  feature :facebooked_connect_login, :default_feature => <<-FEATURE
    <cms:no_user><cms:login_button/></cms:no_user>
    <cms:user><cms:profile_pic/> <cms:name/> <cms:logout>log out</cms:logout></cms:user>
    <cms:connect_form/>
  FEATURE

  def facebooked_connect_login_feature(data)
    webiva_feature(:facebooked_connect_login,data) do |c|
      c.expansion_tag('user') { |t| t.locals.user = data[:fb_user] }

      fb_user_tags(c, 'user')

      c.define_tag("user:logout") do |t|
        logout_url = "#{self.site_node.node_path}?cms_logout=1"
        options = (t.attr || {}).merge('href' => 'javascript:void(0);', 'onclick' => "Facebooked.logout('#{logout_url}')")
        content_tag('a', t.expand || 'Log out'.t, options)
      end

      fb_login_tags(c, 'no_user', data[:onlogin])
    end
  end

  feature :facebooked_connect_visitors, :default_feature => <<-FEATURE
  <cms:users>
    <h3>Latest Visitors</h3>
    <cms:user>
     <cms:profile_pic linked="true"/>
     <cms:multiple value="3"><br/></cms:multiple>
    </cms:user>
  </cms:users>
  FEATURE

  def facebooked_connect_visitors_feature(data)
    webiva_feature(:facebooked_connect_visitors,data) do |c|
      c.loop_tag('user') { |t| data[:visitors] }
        fb_user_tags(c, 'user')
      c.pagelist_tag('pages', :field => 'fb_user_page' ) { |t| data[:pages] }
    end
  end

  feature :facebooked_connect_user, :default_feature => <<-FEATURE
    <cms:user><cms:profile_pic/> <cms:name/></cms:user>
  FEATURE

  def facebooked_connect_user_feature(data)
    webiva_feature(:facebooked_connect_user,data) do |c|
      c.expansion_tag('user') { |t| t.locals.user = data[:fb_user] }
      fb_user_tags(c, 'user')
    end
  end

  def fb_login_tags(context, base='no_user', onlogin=nil)
    onlogin ||= 'window.location.reload(true);'
    context.define_tag("#{base}:login_button") do |t|
      options = {'v' => 2, 'size' => 'small', 'onlogin' => onlogin}.merge(t.attr)
      fbml_tag('login-button', t.expand || 'Connect with Facebook'.t, options)
    end
  end

  def fb_user_tags(context, base='user')
    context.define_tag("#{base}:name") do |t|
      options = {'uid' => t.locals.user.uid, 'useyou' => 'false', 'linked' => 'false'}.merge(t.attr)
      fbml_tag('name', t.expand, options)
    end

    context.define_tag("#{base}:profile_pic") do |t|
      options = {'uid' => t.locals.user.uid, 'size' => 'thumb', 'linked' => 'false'}.merge(t.attr)
      fbml_tag('profile-pic', t.expand, options)
    end

    context.define_tag("#{base}:status") do |t|
      options = {'uid' => t.locals.user.uid, 'linked' => 'true'}.merge(t.attr)
      fbml_tag('user-status', t.expand, options)
    end

    context.define_tag("#{base}:pronoun") do |t|
      options = {'uid' => t.locals.user.uid, 'useyou' => 'false'}.merge(t.attr)
      fbml_tag('pronoun', t.expand, options)
    end
  end

  def fb_connect_form(context, data)
    context.define_tag('connect_form') do |t|
      width = t.attr['width'] || 600
      serverfbml_tag('connect-form', "\n", 'serverfbml' => {'style' => "width:#{width}px;"}, 'action' => Configuration.domain_link('/'))
    end
  end

  def fbml_tag(name, content=nil, options={})
    content_tag("fb:#{name}", content, options)
  end

  def serverfbml_tag(name, content=nil, options={})
    serverfbml_options = options.delete('serverfbml') || {}
    fbml_tag('serverfbml', "\n" + content_tag('script', "\n" + fbml_tag(name, content, options) + "\n", 'type' => 'text/fbml') + "\n", serverfbml_options) + "\n"
  end
end
