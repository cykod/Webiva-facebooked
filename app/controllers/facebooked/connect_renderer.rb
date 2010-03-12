class Facebooked::ConnectRenderer < ParagraphRenderer

  features '/facebooked/connect_feature'

  paragraph :login

  def login
    @options = paragraph_options(:login)

    if editor?
      render_paragraph :feature => :facebooked_connect_login
      return
    end

    @logged_in = self.facebook_client.validate_fb_cookies(cookies)
    if @logged_in
      @fb_user = FacebookedUser.push_facebook_user self.facebook_client, myself

      if myself.id != @fb_user.end_user_id
        paragraph_action(@fb_user.end_user.action('/facebook/connect/login'))
        process_login @fb_user.end_user

        if @options.access_token_id && ! myself.has_token?(@options.access_token_id)
          redirect_paragraph :site_node => @options.edit_account_page_id
        elsif @options.forward_login == 'yes' && session[:lock_lockout]
          lock_logout = session[:lock_lockout]
          session[:lock_lockout] = nil
          redirect_paragraph lock_logout
        elsif @options.destination_page_id
          redirect_paragraph :site_node => @options.destination_page_id
        else
          redirect_paragraph :page
        end

        return
      elsif @options.access_token_id && session[:fb_access_token] != @options.access_token_id
        if ! myself.has_token?(@options.access_token_id)
          if self.site_node.id != @options.edit_account_page_id
            redirect_paragraph :site_node => @options.edit_account_page_id
            return
          end
        else
          session[:fb_access_token] = @options.access_token_id
        end
      end
    elsif params[:cms_logout]
      paragraph_action(myself.action('/facebook/connect/logout')) if myself.id
      process_logout
      redirect_paragraph :page
      return
    end

    render_paragraph :feature => :facebooked_connect_login
  end


  protected

  def facebook_client
    @facebook_client ||= Facebooked::AdminController.facebook_client
  end
end
