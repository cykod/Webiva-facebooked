
class FacebookedClient
  attr_accessor :error
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
    reset
  end

  def reset
    @uid = nil
    @session_key = nil
    @session_secret = nil
    @session_expires = nil
    @fb_params = {}
  end

  def validate_fb_params(params={}, timeout=nil, namespace='fb_sig')
    arguments = {}
    params.each do |k,v|
      next unless k.index(namespace) == 0
      arguments[k.sub(namespace, 'fb_sig')] = v
    end

    reset

    if ! arguments.empty? && MiniFB.verify_signature(@secret, arguments)
      @fb_params = arguments
      return ! self.expired?
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

  def expired?
    return false if self.session_expires.nil?
    self.session_expires <= Time.now
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
    self.call('auth.expireSession')
  end

  def has_app_permission(extended_permissions)
    extended_permissions = extended_permissions.join(',') if extended_permissions.is_a?(Array)
    self.call('users.hasAppPermission', 'ext_perm' => extended_permissions)
  end

  def query(query)
    options = {'query' => query}
    self.call('fql.query', options)
  end

  def facebook_app(data={})
    return @app if @app
    @app = Application.new(self, data)
    @app.get_app_properties unless @app[:app_id]
    @app
  end

  def call(method, options={})
    options['session_key'] = self.session_key if self.session_key
    logger.info "Facebook API Call: #{method} with #{options}"
    begin
      self.error = nil
      MiniFB.call(@api_key, @secret, method, options)
    rescue FacebookError => e
      self.error = e
      logger.error "#{method} failed: #{e}"
    rescue Exception => e
      logger.error "#{method} failed: #{e}"
      nil
    end
  end

  class Application
    FIELDS = [:about_url, :app_id, :application_name, :authorize_url, :base_domain, :base_domains, :callback_url, :canvas_name, :connect_logo_url, :connect_preview_template, :connect_reclaim_url, :connect_url, :contact_email, :creator_uid, :dashboard_url, :default_column, :description, :desktop, :dev_mode, :edit_url, :email, :email_domain, :help_url, :icon_url, :iframe_enable_util, :ignore_ip_whitelist_for_ss, :info_changed_url, :installable, :ip_list, :is_mobile, :logo_url, :message_action, :post_authorize_redirect_url, :preload_fql, :privacy_url, :private_install, :profile_tab_url, :publish_action, :publish_self_action, :publish_self_url, :publish_url, :quick_transitions, :support_url, :tab_default_name, :targeted, :tos_url, :uninstall_url, :use_iframe, :video_rentals, :wide_mode]

    def self.all_fields
      FIELDS.join(",")
    end

    def initialize(client, data)
      @client = client
      @fb_hash = data
    end

    def [](key)
      @fb_hash[key]
    end

    def data
      @fb_hash
    end

    def get_app_properties
      xml = @client.call('Admin.getAppProperties', {'properties' => self.class.all_fields, 'format' => 'XML'})
      return unless xml
      response = Hash.from_xml(xml)

      if response['error_response']
        @client.error = MiniFB::FaceBookError.new(response['error_response']['error_code'], response['error_response']['error_msg'])
        return
      end

      return unless response['Admin_getAppProperties_response']
      @fb_hash = JSON.parse(response['Admin_getAppProperties_response']).symbolize_keys
    end
  end
end
