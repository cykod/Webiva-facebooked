
class Facebooked::AdminController < ModuleController

  component_info 'Facebooked', :description => 'Facebook Support', 
                               :access => :public
                              
  # Register a handler feature
  register_permission_category :facebooked, "Facebook" ,"Permissions related to Facebook"
  
  register_permissions :facebooked, [ [ :manage, 'Manage Facebook', 'Manage Facebook' ],
                                      [ :config, 'Configure Facebook', 'Configure Facebook' ]
                                  ]

  register_handler :page, :post_process, 'FacebookedPageProcessor'
  register_handler :editor, :auth_login_feature, "Facebooked::LoginExtension"

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
    
    if request.post? && @options.valid?
      Configuration.set_config_model(@options)
      flash[:notice] = "Updated Facebook module options".t 
      redirect_to :action => 'configure_facebook'
      return
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
    attributes :application_name => nil, :application_id => nil, :api_key => nil, :secret => nil, :email_permission => nil

    validates_presence_of :application_name, :application_id, :api_key, :secret

    integer_options :application_id

    options_form(
                 fld(:application_name, :text_field, :label => 'Application Name'),
                 fld(:application_id, :text_field, :label => 'Application ID'),
                 fld(:api_key, :text_field, :label => 'API Key'),
                 fld(:secret, :text_field, :label => 'Secret'),
                 fld(:email_permission, :select, :options => :email_permission_options, :label => 'Permission to email')
                 )

    def self.email_permission_options
      [['Not Required', nil], ['Required', 'required']]
    end

    def feature_loader_url
      'http://static.ak.connect.facebook.com/js/api_lib/v0.4/FeatureLoader.js.php/en_US'
    end
  end
  
end
