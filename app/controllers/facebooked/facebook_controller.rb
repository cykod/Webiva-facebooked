
class Facebooked::FacebookController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:install, :uninstall]

  def install
    if request.post? && self.facebook_client.validate_fb_params(params)
      @fb_user = FacebookedUser.find_by_uid(self.facebook_client.uid)
      @fb_user.authorize if @fb_user
    end
    render :nothing => true
  end

  def uninstall
    if request.post? && self.facebook_client.validate_fb_params(params)
      @fb_user = FacebookedUser.find_by_uid(self.facebook_client.uid)
      @fb_user.deactivate! if @fb_user
    end
    render :nothing => true
  end

  protected

  def facebook_client
    @facebook_client ||= Facebooked::AdminController.facebook_client
  end
end
