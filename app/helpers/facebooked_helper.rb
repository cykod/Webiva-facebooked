
module FacebookedHelper
  include EscapeHelper
  include ActionView::Helpers::TagHelper

  def publish_stream(stream)
    action_links = stream.action_links ? stream.action_links.to_json : 'null'
    target_id = stream.target_id ? stream.target_id : 'null'
    user_message_prompt = stream.user_message_prompt ? "\"#{vh stream.user_message_prompt}\"" : 'null'
    callback = stream.callback ? stream.callback : 'null'
    auto_publish = stream.auto_publish ? 'true' : 'false'
    actor_id = stream.actor_id ? stream.actor_id : 'null'
    "FB.Connect.streamPublish(\"#{vh stream.user_message}\", #{stream.attachment.to_h.to_json}, #{action_links}, #{target_id}, #{user_message_prompt}, #{callback}, #{auto_publish}, #{actor_id});"
  end

  def request_form(form)
    options = form.to_h

    content = form.message
    form.choices.each do |choice|
      content << tag('fb:req-choice', choice.to_h)
    end
    options[:content] = content

    options['serverfbml'] = {:width=> form.selector.width }

    content = fbml_tag('multi-friend-selector', nil, form.selector.to_h)
    if form.selector.condensed
      content << tag('fb:request-form-submit')
    end

    serverfbml_tag('request-form', content, options)
  end

  def fbml_tag(name, content=nil, options={})
    content_tag("fb:#{name}", content, options)
  end

  def serverfbml_tag(name, content=nil, options={})
    serverfbml_options = options.delete('serverfbml') || {}
    fbml_tag('serverfbml', "\n" + content_tag('script', "\n" + fbml_tag('fbml', "\n" + fbml_tag(name, content, options) + "\n") + "\n", 'type' => 'text/fbml') + "\n", serverfbml_options) + "\n"
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

    context.define_tag("#{base}:first_name") do |t|
      options = {'uid' => t.locals.user.uid, 'useyou' => 'false', 'linked' => 'false', 'firstnameonly' => 'true'}.merge(t.attr)
      fbml_tag('name', t.expand, options)
    end

    context.define_tag("#{base}:last_name") do |t|
      options = {'uid' => t.locals.user.uid, 'useyou' => 'false', 'linked' => 'false', 'lastnameonly' => 'true'}.merge(t.attr)
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
end
