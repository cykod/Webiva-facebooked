
class Facebooked::AppRenderer < ParagraphRenderer

  features '/facebooked/app_feature'

  paragraph :login
  paragraph :friend_rewards
  paragraph :friends

  def login
    return render_paragraph :text => 'Facebook Application Login' if editor?

    # rendering a facebook tab
    return render_paragraph(:nothing => true) if self.controller.is_a?(Facebooked::TabController)

    return render_paragraph(:nothing => true) if self.logged_in?

    session[:lock_lockout] = self.lock_lockout_url
    data_paragraph :type => 'text/html', :text => login_html
  end

  def friend_rewards
    @options = paragraph_options :friend_rewards
    
    if editor?
      @friends = OauthUser.all :limit => 10, :conditions => {:provider => 'facebook'}
      render_paragraph :feature => :facebooked_app_friend_rewards
      return
    end
    
    return render_paragraph(:nothing => true) unless self.logged_in?

    @oauth_user = self.provider.push_oauth_user myself
    @friends = []
    
    # find my friends
    ids = self.provider.friends.collect { |f| f['id'] }
    unless ids.empty?
      # users that registered before me
      scope = OauthUser.scoped :conditions => ['end_user_id < ?', myself.id]
      scope = scope.scoped :conditions => {:provider => 'facebook', :provider_id => ids}
      @friends = scope.all
      @options.reward @oauth_user, @friends
    end
    
    render_paragraph :feature => :facebooked_app_friend_rewards
  end

  def friends
    @options = paragraph_options :friends
    
    if editor?
      @friends = OauthUser.all :limit => 10, :conditions => {:provider => 'facebook'}
      render_paragraph :feature => :facebooked_app_friends
      return
    end
    
    return render_paragraph(:nothing => true) unless self.logged_in?

    @oauth_user = self.provider.push_oauth_user myself
    @friends = []
    
    # find my friends
    ids = self.provider.friends.collect { |f| f['id'] }
    unless ids.empty?
      @friends = OauthUser.all :conditions => {:provider => 'facebook', :provider_id => ids}, :include => :end_user
    end

    if SiteModule.module_enabled?('user_profile')
      @profile_entries = UserProfileEntry.fetch_entries(@friends.map(&:end_user_id).compact).index_by(&:end_user_id)
    end
    
    render_paragraph :feature => :facebooked_app_friends
  end

  protected

  def logged_in?
    self.provider.logged_in?
  end

  def provider
    @provider ||= Facebooked::OauthProvider.new session
  end

  def login_html
    <<-LOGIN
<html>
<head>
<script type="text/javascript">
top.location = "#{url_for :controller => '/facebooked/client', :action => 'login'}";
</script>
</head>
</html>
    LOGIN
  end

  # removes the signed_request from the url
  def lock_lockout_url
    url = request.request_uri
    url, query = url.split '?'
    query = query.split('&').map { |p| p.match(/^signed_request=/) ? nil : p }.compact.join('&') unless query.blank?
    url = "#{url}?#{query}" unless query.blank?
    url
  end
end
