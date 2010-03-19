require  File.expand_path(File.dirname(__FILE__)) + "/../../../../spec/spec_helper"

activate_module('facebooked')

module FacebookedSpecHelper
  def facebook_sign_params(arguments, secret, namespace='fb_sig')
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

  def create_valid_facebook_cookies(uid=1111222233335)
    cookies = {
      "#{@facebook_api_key}_user" => uid.to_s,
      "#{@facebook_api_key}_session_key" => 'user_session_key',
      "#{@facebook_api_key}_ss" => 'user_session_secret',
      "#{@facebook_api_key}_expires" => 2.hours.from_now.to_i.to_s
    }
    cookies[@facebook_api_key] = facebook_sign_params(cookies, @facebook_secret, @facebook_api_key)
    cookies
  end

  def create_facebook_client(api_key='myfacebookapikey', secret='myfacebooksecret')
    @facebook_api_key = api_key
    @facebook_secret = secret
    @facebook_client = FacebookedClient.new(@facebook_api_key, @facebook_secret)
  end

  def mock_mini_fb_facebook_call(method, data)
    MiniFB.should_receive(:call).with(anything, anything, method, anything).and_return(data)
  end
end
