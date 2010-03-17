
module FacebookedHelper
  include EscapeHelper

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

    options['serverfbml'] = {:style => "width:#{form.selector.width}px"}

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
end
