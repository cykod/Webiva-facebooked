class Facebooked::ConnectRenderer < ParagraphRenderer

  features '/facebooked/connect_feature'

  paragraph :login
  paragraph :visitors
  paragraph :user
  paragraph :fan_box
  paragraph :comments
  paragraph :live_stream

  def login
    @options = paragraph_options(:login)

    if editor?
      render_paragraph :feature => :facebooked_connect_login
      return
    end

    @logged_in = self.facebook_client.validate_fb_cookies(cookies)
    if @logged_in
      @fb_user = FacebookedUser.push_facebook_user self.facebook_client, myself

      if @fb_user
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
      end

    elsif params[:cms_logout]
      paragraph_action(myself.action('/facebook/connect/logout')) if myself.id
      process_logout
      redirect_paragraph :page
      return
    end

    render_paragraph :feature => :facebooked_connect_login
  end

  def visitors
    @options = paragraph_options(:visitors)

    user_page = (params[:fb_user_page] || 1).to_i

    @pages, @visitors = FacebookedUser.active_users.paginate(user_page, :per_page => @options.visitors_to_display, :order => 'created_at DESC' )

    render_paragraph :feature => :facebooked_connect_visitors
  end

  def user
    @options = paragraph_options(:user)

    @logged_in = self.facebook_client.validate_fb_cookies(cookies)

    @fb_user_id = @options.facebook_user_id
    if @fb_user_id.nil? && @logged_in
      @fb_user_id = self.facebook_client.uid
    end

    display_string = @logged_in ? 'logged_in' : 'not_logged_in'
    display_string << "_#{@fb_user_id}"
    result = renderer_cache(nil, display_string) do |cache|
      @fb_user = FacebookedUser.find_by_uid(@fb_user_id) || FacebookedUser.new(@fb_user_id)
      cache[:output] = facebooked_connect_user_feature
    end

    render_paragraph :text => result.output
  end

  def fan_box
    @options = paragraph_options(:fan_box)

    @logged_in = self.facebook_client.validate_fb_cookies(cookies)
    @fb_user_id = self.facebook_client.uid if @logged_in

    display_string = @logged_in ? 'logged_in' : 'not_logged_in'
    display_string << "_#{@fb_user_id}"
    result = renderer_cache(nil, display_string) do |cache|
      @fb_user = FacebookedUser.find_by_uid(@fb_user_id) if @fb_user_id
      cache[:output] = facebooked_connect_fan_box_feature
    end

    render_paragraph :text => result.output
  end

  def comments
    @options = paragraph_options(:comments)

    @logged_in = self.facebook_client.validate_fb_cookies(cookies)
    @fb_user_id = self.facebook_client.uid if @logged_in

    display_string = @logged_in ? 'logged_in' : 'not_logged_in'
    display_string << "_#{@fb_user_id}"
    result = renderer_cache(nil, display_string) do |cache|
      @fb_user = FacebookedUser.find_by_uid(@fb_user_id) if @fb_user_id
      cache[:output] = facebooked_connect_comments_feature
    end

    @xid = @options.xid.blank? ? CGI::escape(paragraph_page_url) : @options.xid
    render_paragraph :text => result.output.gsub('%%CMS:XID%%', @xid)
  end

  def live_stream
    @options = paragraph_options(:live_stream)

    @logged_in = self.facebook_client.validate_fb_cookies(cookies)
    @fb_user_id = self.facebook_client.uid if @logged_in

    display_string = @logged_in ? 'logged_in' : 'not_logged_in'
    display_string << "_#{@fb_user_id}"
    result = renderer_cache(nil, display_string) do |cache|
      @fb_user = FacebookedUser.find_by_uid(@fb_user_id) if @fb_user_id
      cache[:output] = facebooked_connect_live_stream_feature
    end

    render_paragraph :text => result.output
  end

  protected

  def facebook_client
    @facebook_client ||= Facebooked::AdminController.facebook_client
  end
end
