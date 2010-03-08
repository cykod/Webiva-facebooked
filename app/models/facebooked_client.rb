
class FacebookedClient
  cattr_accessor :logger
  @@logger = ActiveRecord::Base.logger

  CLIENT_CACHE_KEY = 'FacebookedClient::MiniFB'

  def self.client(app_id=nil, secret=nil)
    client = DataCache.local_cache CLIENT_CACHE_KEY
    return client if client

    client = FacebookedClient.new(app_id, secret)
  end

  def initialize(api_key, secret)
    @api_key = api_key
    @secret = secret
    @fb_params = {}
  end

  def validate_fb_params(params={}, timeout=nil, namespace='fb_sig')
    arguments = {}
    params.each do |k,v|
      next unless k.index(namespace) == 0
      arguments[k.sub(namespace, 'fb_sig')] = v
    end

    if ! arguments.empty? && MiniFB.verify_signature(@secret, arguments)
      @fb_params = arguments
      return true
    else
      return false
    end
  end

  def validate_fb_cookies(cookies, timeout=nil)
    validate_fb_params(cookies, timeout, @api_key)
  end

  def validate_fb_post(params, timeout=nil)
    validate_fb_params(params, timeout, 'fb_post_sig')
  end

  def uid
    @uid ||= @fb_params['fb_sig_user']
  end

  def session_key
    @session_key ||= @fb_params['fb_sig_session_key']
  end

  def session
    @session ||= MiniFB::Session.new @api_key, @secret, self.session_key, self.uid
  end
end
