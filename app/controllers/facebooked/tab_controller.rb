
class Facebooked::TabController < ModuleAppController
  protect_from_forgery :except => :index

  component_info 'Facebooked'

  skip_before_filter :handle_page

  def index
    return render(:nothing => true) unless Facebooked::AdminController.module_options.tab_node
    params[:path] = Facebooked::AdminController.module_options.tab_node.link[1..-1].split('/')
    handle_page
    render :action => 'index'
  end
end
