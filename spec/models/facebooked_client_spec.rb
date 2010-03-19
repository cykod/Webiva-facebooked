require  File.expand_path(File.dirname(__FILE__)) + "/../facebooked_spec_helper"

describe FacebookedClient do

  include FacebookedSpecHelper

  it "should validate fb parameters" do
    uid = 1111222233335
    api_key = 'myfacebookapikey'
    secret = 'myfacebooksecret'
    @client = FacebookedClient.client(api_key, secret)
    cookies = {
      "#{api_key}_user" => uid.to_s,
      "#{api_key}_session_key" => 'user_session_secret',
      "#{api_key}_ss" => 'user_ss',
      "#{api_key}_expires" => 2.hours.from_now.to_i.to_s
    }
    cookies[api_key] = facebook_sign_params(cookies, secret, api_key)

    @client.validate_fb_cookies(cookies).should be_true

    cookies[api_key] = 'invalid'
    @client.validate_fb_cookies(cookies).should be_false

    cookies["#{api_key}_expires"] = 1.minute.ago.to_i.to_s
    cookies[api_key] = facebook_sign_params(cookies, secret, api_key)
    @client.validate_fb_cookies(cookies)
  end

end
