
class Facebooked::FacebookController < ModuleController

  component_info 'Facebooked'
                              
  cms_admin_paths "options",
    "Facebook Options" => { :controller => '/facebooked/admin', :action => 'options' },
    "Options" => { :controller => '/options' },
    "Modules" => { :controller => '/modules' },
    "Members" => { :controller => '/members' }

  permit 'facebooked_manage'

  public

end
