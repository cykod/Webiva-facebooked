require  File.expand_path(File.dirname(__FILE__)) + "/../../../../spec/spec_helper"

activate_module('facebooked')

module FacebookedSpecHelper
  def facebook_sign_params(arguments, secret, namespace='fb_sig')
    arguments.delete( namespace )

    signed = Hash.new

    arguments.each do |k, v|
      if k =~ /^#{namespace}_(.*)/ then
        signed[$1] = v
      end
    end

    arg_string = String.new
    signed.sort.each { |kv| arg_string << kv[0] << "=" << kv[1] }
    Digest::MD5.hexdigest( arg_string + secret )
  end


  def create_facebook_client(uid=1111222233335, api_key='myfacebookapikey', secret='myfacebooksecret')
    @facebook_client = FacebookedClient.new(api_key, secret)
    cookies = {
      "#{api_key}_user" => uid.to_s,
      "#{api_key}_session_key" => 'user_session_key',
      "#{api_key}_ss" => 'user_session_secret',
      "#{api_key}_expires" => 2.hours.from_now.to_i.to_s
    }
    cookies[api_key] = facebook_sign_params(cookies, secret, api_key)
    @facebook_client.validate_fb_cookies(cookies)
    @facebook_client
  end

  def mock_mini_fb_facebook_call(method, data)
    MiniFB.should_receive(:call).with(anything, anything, method, anything).and_return(data)
  end
end
