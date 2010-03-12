class Facebooked::ConnectFeature < ParagraphFeature


  feature :facebooked_connect_login, :default_feature => <<-FEATURE
    <cms:no_user><cms:login_button/></cms:no_user>
    <cms:user><cms:profile_pic/> <cms:name/> <cms:logout>log out</cms:logout></cms:user>
  FEATURE
  

  def facebooked_connect_login_feature(data)
    webiva_feature(:facebooked_connect_login,data) do |c|
      c.expansion_tag('user') { |t| t.locals.user = data[:fb_user] }

      fb_user_tags(c, 'user')

      fb_login_tags(c, 'no_user', data[:onlogin])
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

    context.define_tag("#{base}:logout") do |t|
      logout_url = "#{self.site_node.node_path}?cms_logout=1"
      options = (t.attr || {}).merge('href' => 'javascript:void(0);', 'onclick' => "FB.Connect.logoutAndRedirect('#{logout_url}')")
      content_tag('a', t.expand || 'Log out'.t, options)
    end
  end

  def fbml_tag(name, content=nil, options={})
    content_tag("fb:#{name}", content, options)
  end
end
