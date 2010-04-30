
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

  def self.facebook_client
    options = self.module_options
    FacebookedClient.client(options.api_key, options.secret)
  end

  class Options < HashModel
    attr_accessor :app_id, :application_name, :connect_url, :email_domain, :authorize_url, :base_domain, :uninstall_url

    attributes :api_key => nil, :secret => nil, :email_permission => nil, :facebook_app_data => {}, :creator_name => nil

    validates_presence_of :api_key, :secret

    options_form(
                 fld(:api_key, :text_field, :label => 'API Key', :required => true),
                 fld(:secret, :text_field, :label => 'Secret', :required => true),
                 fld(:email_permission, :select, :options => :email_permission_options, :label => 'Permission to email')
                 )

    def validate
      if self.facebook_client.error
        errors.add(:api_key, 'is invalid')
        errors.add(:secret, 'is invalid')
      else
        errors.add(:connect_url, 'is invalid') if self.facebook_app_data[:connect_url].blank? || ! self.facebook_app_data[:connect_url].include?(Configuration.domain_link('/'))
      end
    end

    def app_id
      self.facebook_app_data[:app_id]
    end

    def application_name
      self.facebook_app_data[:application_name]
    end

    def connect_url
      self.facebook_app_data[:connect_url]
    end

    def email_domain
      self.facebook_app_data[:email_domain]
    end

    def base_domain
      self.facebook_app_data[:base_domain]
    end

    def authorize_url
      self.facebook_app_data[:authorize_url]
    end

    def uninstall_url
      self.facebook_app_data[:uninstall_url]
    end

    def self.email_permission_options
      [['Not Required', nil], ['Required', 'required']]
    end

    def feature_loader_url
      'http://static.ak.connect.facebook.com/js/api_lib/v0.4/FeatureLoader.js.php/en_US'
    end

    def facebook_client
      @facebook_client ||= FacebookedClient.new(self.api_key, self.secret)
    end

    def facebook_app
      self.facebook_client.facebook_app(self.facebook_app_data)
    end

    def fetch_facebook_app_data
      self.creator_name = nil
      self.facebook_app_data = self.facebook_app.get_app_properties || {}
      if self.facebook_app_data[:creator_uid]
        user = self.facebook_client.fetch_user(self.facebook_app_data[:creator_uid])
        if user
          self.creator_name = user[:name]
        end
      end
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
