
class Facebooked::AdminController < ModuleController

  component_info 'Facebooked', :description => 'Facebook Support', 
                               :access => :private,
                               :dependencies => ['oauth']

  # Register a handler feature
  register_permission_category :facebooked, "Facebook" ,"Permissions related to Facebook"
  
  register_permissions :facebooked, [ [ :manage, 'Manage Facebook', 'Manage Facebook' ],
                                      [ :config, 'Configure Facebook', 'Configure Facebook' ]
                                  ]

  register_handler :post_stream, :share, 'Facebooked::Share::Media'
  register_handler :oauth, :provider, 'Facebooked::OauthProvider'
  register_handler :page, :post_process, 'FacebookedPageProcessor'
  register_handler :page, :before_request, 'FacebookedPageProcessor'

  cms_admin_paths "options",
    "Facebook Options" => { :action => 'options' },
    "Options" => { :controller => '/options' },
    "Modules" => { :controller => '/modules' },
    "Members" => { :controller => '/members' }

  permit 'facebooked_config'

  public 
 
  def options
    cms_page_path ['Options','Modules'],"Facebook Options"
    
    @options = self.class.module_options(params[:options])

    if request.post?
      @options.fetch_facebook_app_data
      if @options.valid?
        Configuration.set_config_model(@options)
        flash[:notice] = "Updated Facebook module options".t 
        redirect_to :controller => '/modules'
        return
      end
    end
  end

  def update_users
    @options = self.class.module_options
    @options.update_users
    cms_page_path ['Options','Modules', "Facebook Options"], 'Facebook User Update'
  end

  def configure_facebook
    cms_page_path ['Options','Modules', "Facebook Options"], "Configure Facebook"

    @options = self.class.module_options
  end

  def self.module_options(vals=nil)
    Configuration.get_config_model(Options,vals)
  end

  class Options < HashModel
    attributes :app_id => nil, :secret => nil, :canvas_page => nil, :facebook_domain_id => nil,
      :user_scopes => [], :friend_scopes => [], :publish_scopes => [], :facebook_app_data => {},
      :tab_id => nil

    validates_presence_of :app_id, :secret

    page_options :tab_id

    options_form(
                 fld(:app_id, :text_field, :label => 'App ID', :required => true),
                 fld(:secret, :text_field, :label => 'Secret', :required => true),
                 fld(:canvas_page, :text_field),
                 fld(:facebook_domain_id, :select, :options => :domain_options),
                 fld(:tab_id, :select, :options => :tab_page_options, :label => 'Facebook Tab Page', :description => "tab page requires a theme with Partial Template turned on in the Options"),
                 fld(:user_scopes, :check_boxes, :options => :user_scopes_options, :separator => '<br/>'),
                 fld(:friend_scopes, :check_boxes, :options => :friend_scopes_options, :separator => '<br/>'),
                 fld(:publish_scopes, :check_boxes, :options => :publish_scopes_options, :separator => '<br/>')
                 )

    def validate
      if self.client_access_token && self.client_data
        self.facebook_app_data[:application_name] = self.client_data[:name]
      else
        errors.add(:app_id, 'is invalid')
        errors.add(:secret, 'is invalid')
      end
    end

    def tab_page_options
      [['--Select page--', nil]] + SiteNode.page_options(false, :version => self.facebook_site_version)
    end

    def domain_options
      Domain.find(:all, :conditions => {:client_id => DomainModel.active_domain[:client_id]}).collect { |d| [d.name, d.id] }
    end

    def application_name
      self.facebook_app_data[:application_name]
    end

    def canvas_url
      "http://apps.facebook.com/#{self.canvas_page}/"
    end

    def canvas_setup_url
      "http://#{self.facebook_domain_url}/"
    end

    def deauthorize_url
      "http://#{self.facebook_domain_url}/website/facebooked/client/deauthorize"
    end

    def tab_url
      "http://#{self.facebook_domain_url}/website/facebooked/tab"
    end

    def facebook_domain
      return @facebook_domain if @facebook_domain
      @facebook_domain = Domain.find_by_id(self.facebook_domain_id) if self.facebook_domain_id
      @facebook_domain ||= Domain.find_by_id DomainModel.active_domain_id
    end

    def facebook_site_version
      @facebook_site_version ||= SiteVersion.find self.facebook_domain.site_version_id
    end

    def facebook_domain_url
      self.facebook_domain.www_prefix ? "www.#{self.facebook_domain.name}" : self.facebook_domain.name
    end

    def self.user_scopes_options
      [ ['Email', 'email'],
        ['Read stream', 'read_stream'],
        ['User about me', 'user_about_me'],
        ['User activities', 'user_activities'],
        ['User birthday', 'user_birthday'],
        ['User education history', 'user_education_history'],
        ['User events', 'user_events'],
        ['User groups', 'user_groups'],
        ['User hometown', 'user_hometown'],
        ['User interests', 'user_interests'],
        ['User likes', 'user_likes'],
        ['User location', 'user_location'],
        ['User notes', 'user_notes'],
        ['User online presence', 'user_online_presence'],
        ['User photo video tags', 'user_photo_video_tags'],
        ['User photos', 'user_photos'],
        ['User relationships', 'user_relationships'],
        ['User religion politics', 'user_religion_politics'],
        ['User status', 'user_status'],
        ['User videos', 'user_videos'],
        ['User website', 'user_website'],
        ['User work history', 'user_work_history'],
        ['Read friend lists', 'read_friendlists'],
        ['Read requests', 'read_requests']]
    end

    def self.friend_scopes_options
      [ ['Friends activities', 'friends_activities'],
        ['Friends birthday', 'friends_birthday'],
        ['Friends education history', 'friends_education_history'],
        ['Friends events', 'friends_events'],
        ['Friends groups', 'friends_groups'],
        ['Friends hometown', 'friends_hometown'],
        ['Friends interests', 'friends_interests'],
        ['Friends likes', 'friends_likes'],
        ['Friends location', 'friends_location'],
        ['Friends notes', 'friends_notes'],
        ['Friends online presence', 'friends_online_presence'],
        ['Friends photo video tags', 'friends_photo_video_tags'],
        ['Friends photos', 'friends_photos'],
        ['Friends relationships', 'friends_relationships'],
        ['Friends religion politics', 'friends_religion_politics'],
        ['Friends status', 'friends_status'],
        ['Friends videos', 'friends_videos'],
        ['Friends website', 'friends_website'],
        ['Friends work history', 'friends_work_history']]
    end

    def self.publish_scopes_options
      [ ['Publish stream', 'publish_stream'],
        ['Create event', 'create_event'],
        ['Rsvp event', 'rsvp_event'],
        ['SMS', 'sms'],
        ['Offline access', 'offline_access']]
    end

    def client
      @client ||= OAuth2::Client.new(self.app_id, self.secret, :site => 'https://graph.facebook.com')
    end

    def facebook
      @facebook ||= OAuth2::AccessToken.new self.client, self.client_access_token, nil
    end

    def client_data
      return @client_data if @client_data

      begin
        @client_data = JSON.parse(self.facebook.get("/#{self.app_id}", {:metadata => 1})).symbolize_keys
      rescue OAuth2::HTTPError, OAuth2::ErrorWithResponse, OAuth2::AccessDenied => e
        Rails.logger.error e
      end

      @client_data
    end

    def client_access_token
      return @client_access_token if @client_access_token

      begin
        response = self.client.request(:post, self.client.access_token_url, {:client_id => self.app_id, :client_secret => self.secret, :type => 'client_cred'})
        params   = Rack::Utils.parse_query(response)
        return @client_access_token = params['access_token']
      rescue Errno::ECONNRESET, SocketError, OAuth2::HTTPError, OAuth2::ErrorWithResponse, OAuth2::AccessDenied => e
        Rails.logger.error e
      end
      nil
    end

    def scopes
      permissions = []
      self.user_scopes.each { |s| permissions << s unless s.blank? }
      self.friend_scopes.each { |s| permissions << s unless s.blank? }
      self.publish_scopes.each { |s| permissions << s unless s.blank? }
      permissions.empty? ? nil : permissions.join(',')
    end
    
    def update_users(opts={})
      OauthUser.all(:conditions => {:provider => 'facebook'}, :include => :end_user).each do |oauth_user|
        next unless oauth_user.end_user
        begin
          sleep 1
          # users are considered deauthorized if we can not return their email field
          data = JSON.parse self.facebook.get("/#{oauth_user.provider_id}?fields=email")
          if data['email']
            oauth_user.end_user.elevate_user_level(EndUser::UserLevel::LEAD) if oauth_user.end_user.user_level < EndUser::UserLevel::LEAD
          else
            oauth_user.end_user.unsubscribe if oauth_user.end_user.user_level != EndUser::UserLevel::OPT_OUT
          end
        rescue Errno::ECONNRESET, SocketError, OAuth2::HTTPError, OAuth2::ErrorWithResponse, OAuth2::AccessDenied, JSON::ParserError => e
          Rails.logger.error e
        end
      end
    end
  end  
end
