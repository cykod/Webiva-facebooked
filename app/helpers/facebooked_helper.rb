
module FacebookedHelper
  include EscapeHelper

  def publish_stream(stream)
    action_links = stream.action_links ? stream.action_links.to_h.to_json : 'null'
    target_id = stream.target_id ? stream.target_id : 'null'
    user_message_prompt = stream.user_message_prompt ? "\"#{vh stream.user_message_prompt}\"" : 'null'
    callback = stream.callback ? stream.callback : 'null'
    auto_publish = stream.auto_publish ? 'true' : 'false'
    actor_id = stream.actor_id ? stream.actor_id : 'null'
    "FB.Connect.streamPublish(\"#{vh stream.user_message}\", #{stream.attachment.to_h.to_json}, #{action_links}, #{target_id}, #{user_message_prompt}, #{callback}, #{auto_publish}, #{actor_id});"
  end
end
