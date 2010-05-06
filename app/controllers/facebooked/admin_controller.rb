
class Facebooked::AdminController < ModuleController

  component_info 'Facebooked', :description => 'Facebook Support', 
                               :access => :public,
                               :dependencies => ['oauth']

  # Register a handler feature
  register_permission_category :facebooked, "Facebook" ,"Permissions related to Facebook"
  
  register_permissions :facebooked, [ [ :manage, 'Manage Facebook', 'Manage Facebook' ],
                                      [ :config, 'Configure Facebook', 'Configure Facebook' ]
                                  ]

  register_handler :post_stream, :share, 'Facebooked::Share::Media'
  register_handler :oauth, :provider, 'Facebooked::OauthProvider'
  register_handler :page, :post_process, 'FacebookedPageProcessor'

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

  def configure_facebook
    cms_page_path ['Options','Modules', "Facebook Options"], "Configure Facebook"

    @options = self.class.module_options
  end

  def self.module_options(vals=nil)
    Configuration.get_config_model(Options,vals)
  end

  class Options < HashModel
    attributes :app_id => nil, :secret => nil, :user_scopes => [], :friend_scopes => [], :publish_scopes => [], :facebook_app_data => {}

    validates_presence_of :app_id, :secret

    options_form(
                 fld(:app_id, :text_field, :label => 'App ID', :required => true),
                 fld(:secret, :text_field, :label => 'Secret', :required => true),
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

    def application_name
      self.facebook_app_data[:application_name]
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

    def client_data
      return @client_data if @client_data

      begin
        access_token = OAuth2::AccessToken.new self.client, self.client_access_token, nil
        @client_data = JSON.parse(access_token.get("/#{self.app_id}", {:metadata => 1})).symbolize_keys
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
      rescue OAuth2::HTTPError, OAuth2::ErrorWithResponse, OAuth2::AccessDenied => e
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
  end
  
end
