
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
    attributes :app_id => nil, :api_key => nil, :secret => nil, :email_permission => nil, :facebook_app_data => {}

    validates_presence_of :app_id, :api_key, :secret

    options_form(
                 fld(:app_id, :text_field, :label => 'App ID', :required => true),
                 fld(:api_key, :text_field, :label => 'API Key', :required => true),
                 fld(:secret, :text_field, :label => 'Secret', :required => true),
                 fld(:email_permission, :select, :options => :email_permission_options, :label => 'Permission to email')
                 )

    def validate
      if self.client_access_token && self.client_data
        self.facebook_app_data[:application_name] = self.client_data[:name]
      else
        errors.add(:app_id, 'is invalid')
        errors.add(:api_key, 'is invalid')
        errors.add(:secret, 'is invalid')
      end
    end

    def application_name
      self.facebook_app_data[:application_name]
    end

    def self.email_permission_options
      [['Not Required', nil], ['Required', 'required']]
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
        response = self.client.request(:post, self.client.access_token_url, {:client_id => self.api_key, :client_secret => self.secret, :type => 'client_cred'})
        params   = Rack::Utils.parse_query(response)
        return @client_access_token = params['access_token']
      rescue OAuth2::HTTPError, OAuth2::ErrorWithResponse, OAuth2::AccessDenied => e
        Rails.logger.error e
      end
      nil
    end

    def scopes
      if self.email_permission == 'required'
        'email'
      else
        nil
      end
    end
  end
  
end
