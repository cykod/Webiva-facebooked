
class Facebooked::LoginExtension < Handlers::ParagraphLoginExtension

  include FacebookedHelper

  def self.editor_auth_login_feature_handler_info
    { 
      :name => 'Facebooked Login Extension',
      :paragraph_options_partial => '/facebooked/handler/auth_login'
    }
  end

  def logged_in(renderer, login_options)
    super

    @logged_in = self.facebook_client.validate_fb_cookies(cookies)
    if @logged_in
      @fb_user = FacebookedUser.push_facebook_user self.facebook_client, myself

      if @fb_user
        if myself.id != @fb_user.end_user_id
          paragraph_action(@fb_user.end_user.action('/facebook/connect/login'))
          process_login @fb_user.end_user

          if @options.access_token_id && ! myself.has_token?(@options.access_token_id)
            return redirect_paragraph :site_node => @options.edit_account_page_id
          elsif @login_options.forward_login == 'yes' && session[:lock_lockout]
            lock_logout = session[:lock_lockout]
            session[:lock_lockout] = nil
            return redirect_paragraph lock_logout
          elsif @login_options.destination_page_id
            return redirect_paragraph :site_node => @login_options.destination_page_id
          else
            return redirect_paragraph :page
          end

        elsif @options.access_token_id && session[:fb_access_token] != @options.access_token_id
          if ! myself.has_token?(@options.access_token_id)
            if @renderer.site_node.id != @options.edit_account_page_id
              return redirect_paragraph :site_node => @options.edit_account_page_id
            end
          else
            session[:fb_access_token] = @options.access_token_id
          end
        end
      end
    end

    nil
  end

  # Called before the feature is displayed
  def feature_data(data)
    data[:facebooked] = {
      :fb_user => @fb_user
    }
  end

  # Adds any feature related tags
  def feature_tags(c, data)
    c.expansion_tag('facebooked') { |t| true }
    c.expansion_tag('facebooked:user') { |t| t.locals.user = data[:facebooked][:fb_user] }

    fb_user_tags(c, 'facebooked:user')

    c.link_tag("facebooked:user:logout") do |t|
      logout_url = "?cms_logout=1"
      {
        :onclick => "Facebooked.logout('#{logout_url}')",
        :href => 'javascript:void(0);'
      }
    end

    fb_login_tags(c, 'facebooked:no_user')

    if data[:facebooked][:fb_user]
      c.link_tag("logged_in:logout") do |t|
        logout_url = "?cms_logout=1"
        {
          :onclick => "Facebooked.logout('#{logout_url}')",
          :href => 'javascript:void(0);'
        }
      end

      end_user = data[:facebooked][:fb_user].end_user
      if end_user && end_user.missing_name?
        uid = data[:facebooked][:fb_user].uid

        c.define_tag 'logged_in:name' do |t|
          fbml_tag('name', nil, 'uid' => uid, 'linked' => 'false', 'useyou' => 'false')
        end

        c.define_tag 'logged_in:first_name' do |t|
          fbml_tag('name', nil, 'uid' => uid, 'linked' => 'false', 'useyou' => 'false', 'firstnameonly' => 'true')
        end

        c.define_tag 'logged_in:last_name' do |t|
          fbml_tag('name', nil, 'uid' => uid, 'linked' => 'false', 'useyou' => 'false', 'lastnameonly' => 'true')
        end
      end
    end
  end

  def facebook_client
    @facebook_client ||= Facebooked::AdminController.facebook_client
  end

  # Paragraph Setup options
  def self.paragraph_options(val={})
    opts = LoginExtensionParagraphOptions.new(val)
  end

  class LoginExtensionParagraphOptions < HashModel
    attributes :access_token_id => nil, :edit_account_page_id => nil

    options_form(
                 fld(:access_token_id, :select, :options => :access_token_options, :label => 'Access Token'),
                 fld(:edit_account_page_id, :select, :options => :page_options, :label => 'Edit Account Page')                 
                 )

    def self.access_token_options
      [['--Select Access Token--', nil]] + AccessToken.user_token_options
    end

    def self.page_options
      [[ '--Stay on Same Page--'.t, nil ]] + SiteNode.page_options()
    end
  end
end
