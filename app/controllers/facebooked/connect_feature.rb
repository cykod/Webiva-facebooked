class Facebooked::ConnectFeature < ParagraphFeature

  include FacebookedHelper

  feature :facebooked_connect_login, :default_feature => <<-FEATURE
    <cms:no_user><cms:login_button/></cms:no_user>
    <cms:user><cms:profile_pic/> <cms:name/> <cms:logout>log out</cms:logout></cms:user>
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
     <cms:profile_pic size="square" linked="false"/>
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
    <cms:user><cms:profile_pic/> <cms:name/> <cms:bookmark/></cms:user>
  FEATURE

  def facebooked_connect_user_feature(data)
    webiva_feature(:facebooked_connect_user,data) do |c|
      c.expansion_tag('user') { |t| t.locals.user = data[:fb_user] }
      fb_user_tags(c, 'user')
    end
  end

  feature :facebooked_connect_fan_box, :default_feature => <<-FEATURE
    <cms:fan_box/>
  FEATURE

  def facebooked_connect_fan_box_feature(data)
    webiva_feature(:facebooked_connect_fan_box,data) do |c|
      c.expansion_tag('user') { |t| t.locals.user = data[:fb_user] }
      fb_user_tags(c, 'user')

      c.define_tag('fan_box') do |t|
        options = {
          'stream' => data[:options].stream ? 1 : 0,
          'connections' => data[:options].connections,
          'width' => data[:options].width,
          'height' => data[:options].height,
          'logobar' => data[:options].logobar ? 1 : 0
        }

        if data[:options].profile_id
          options['profile_id'] = data[:options].profile_id
        else
          options['name'] = data[:options].name
        end

        options['css'] = data[:options].css_file.full_url if data[:options].css_file

        fbml_tag('fan', '', options)
      end
    end
  end

  feature :facebooked_connect_comments, :default_feature => <<-FEATURE
    <cms:comments/>
  FEATURE

  def facebooked_connect_comments_feature(data)
    webiva_feature(:facebooked_connect_comments,data) do |c|
      c.expansion_tag('user') { |t| t.locals.user = data[:fb_user] }
      fb_user_tags(c, 'user')

      c.define_tag('comments') do |t|
        options = {
          'xid' => '%%CMS:XID%%',
          'numposts' => data[:options].numposts,
          'width' => data[:options].width,
          'simple' => data[:options].simple ? 1 : 0,
          'reverse' => data[:options].reverse ? 1 : 0,
          'publish_feed' => data[:options].publish_feed ? 1 : 0,
        }

        options['title'] = data[:options].title unless data[:options].title.blank?
        options['url'] = data[:options].url unless data[:options].url.blank?
        options['css'] = data[:options].css_file.full_url if data[:options].css_file

        fbml_tag('comments', '', options)
      end
    end
  end

  feature :facebooked_connect_live_stream, :default_feature => <<-FEATURE
    <cms:live_stream/>
  FEATURE

  def facebooked_connect_live_stream_feature(data)
    webiva_feature(:facebooked_connect_live_stream,data) do |c|
      c.expansion_tag('user') { |t| t.locals.user = data[:fb_user] }
      fb_user_tags(c, 'user')

      c.define_tag('live_stream') do |t|
        options = {
          'xid' => data[:options].xid,
          'width' => data[:options].width,
          'height' => data[:options].height
        }

        fbml_tag('live-stream', '', options)
      end
    end
  end

  feature :facebooked_connect_share_button, :default_feature => <<-FEATURE
    <cms:share_button/>
  FEATURE

  def facebooked_connect_share_button_feature(data)
    webiva_feature(:facebooked_connect_share_button,data) do |c|
      c.expansion_tag('user') { |t| t.locals.user = data[:fb_user] }
      fb_user_tags(c, 'user')

      c.define_tag('share_button') do |t|
        options = {
          'class' => data[:options].class_name,
          'type' => data[:options].type,
          'url' => '%%CMS:URL%%'
        }

        fbml_tag('share-button', '', options)
      end
    end
  end

  feature :facebooked_connect_stream_publish, :default_feature => <<-FEATURE
    <cms:stream_publish_link>Publish</cms:stream_publish_link>
  FEATURE

  def facebooked_connect_stream_publish_feature(data)
    webiva_feature(:facebooked_connect_stream_publish,data) do |c|
      c.expansion_tag('user') { |t| t.locals.user = data[:fb_user] }
      fb_user_tags(c, 'user')

      c.define_tag('stream_publish_link') do |t|
        content_tag('a', t.expand, 'href' => 'javascript:void(0);', 'onclick' => publish_stream(data[:options].stream))
      end
    end
  end

  feature :facebooked_connect_request_form, :default_feature => <<-FEATURE
  <cms:user>
    Request Form
    <cms:request_form/>
  </cms:user>
  FEATURE

  def facebooked_connect_request_form_feature(data)
    webiva_feature(:facebooked_connect_request_form,data) do |c|
      c.expansion_tag('user') { |t| t.locals.user = data[:fb_user] }
      fb_user_tags(c, 'user')

      c.define_tag('user:request_form') do |t|
        request_form(data[:options].request_form)
#        serverfbml_tag('request-form',
#                       fbml_tag('multi-friend-selector', nil, :showborder => "false", :condensed =>"true", :actiontext => "Invite your friends to this network."),
#                       :action => "http://doug.dev/about-us", :method => "POST", :invite => "false", :type => "sample network", :content => "This network is the best place on Facebook for viewing, sharing and giving friends the highest quality stuff. Join me on this network! <fb:req-choice url='http://www.facebook.com/login.php?api_key=78' label='Check out this network!' />", 'serverfbml' => {'style' => 'width:760px;'}
#                       )
      end
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

    context.define_tag("#{base}:bookmark") do |t|
      options = {'type' => 'off-facebook'}.merge(t.attr)
      fbml_tag('bookmark', '', options)
    end
  end

  def fb_connect_form(context, data)
    context.define_tag('connect_form') do |t|
      width = t.attr['width'] || 600
      serverfbml_tag('connect-form', "\n", 'serverfbml' => {'style' => "width:#{width}px;"}, 'action' => Configuration.domain_link('/'))
    end
  end
end
