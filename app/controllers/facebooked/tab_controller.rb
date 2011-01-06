
class Facebooked::TabController < ModuleAppController
  protect_from_forgery :except => :view

  component_info 'Facebooked'

  skip_before_filter :handle_page

  def view
    params[:path] = Facebooked::AdminController.module_options.tab_node.link[1..-1].split('/')
    handle_page
    render :action => 'view'
  end
end
