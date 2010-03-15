
class FacebookedClient
  cattr_accessor :logger
  @@logger = ActiveRecord::Base.logger

  CLIENT_CACHE_KEY = 'FacebookedClient::MiniFB'

  def self.client(api_key=nil, secret=nil)
    client = DataCache.local_cache CLIENT_CACHE_KEY
    return client if client

    raise "FacebookedClient was not initialized" unless api_key && secret

    client = FacebookedClient.new(api_key, secret)
    DataCache.put_local_cache CLIENT_CACHE_KEY, client
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

  def session_secret
    @session_secret ||= @fb_params['fb_sig_ss']
  end

  def session_expires
    return @session_expires if @session_expires

    if @fb_params['fb_sig_expires']
      @session_expires = Time.at(@fb_params['fb_sig_expires'].to_i)
    else
      nil
    end
  end

  def session
    @session ||= MiniFB::Session.new @api_key, @secret, self.session_key, self.uid
  end

  def user
    begin
      self.session.user
    rescue MiniFB::FaceBookError => e
      logger.error e
      nil
    end
  end

  def clear_cookies(cookies)
    cookies.each do |k,v|
      cookies.delete k if k.to_s.include?(@api_key)
    end
  end

  def expire_session
    self.call('auth.expiresession')
  end

  def has_app_permission(extended_permissions)
    extended_permissions = extended_permissions.join(',') if extended_permissions.is_a?(Array)
    self.call('users.hasAppPermission', 'ext_perm' => extended_permissions)
  end

  def query(query)
    options = {'query' => query}
    self.call('fql.query', options)
  end

  def call(method, options={})
    options['session_key'] = self.session_key if self.session_key
    logger.info "Facebook API Call: #{method} with #{options}"
    begin
      MiniFB.call(@api_key, @secret, method, options)
    rescue Exception => e
      logger.error "#{method} failed: #{e}"
      nil
    end
  end
end
