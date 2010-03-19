require  File.expand_path(File.dirname(__FILE__)) + '/../../facebooked_spec_helper'

describe Facebooked::ConnectFeature, :type => :view do

  include FacebookedSpecHelper

  reset_domain_tables :end_user, :facebooked_users

  describe "Page Feature" do
    before(:each) do
      @user = EndUser.push_target('test@test.dev')
      @fb_user = FacebookedUser.create :uid => 1, :email => 'test-app@proxy.facebook.com', :end_user_id => @user.id
      @feature = build_feature('/facebooked/connect_feature')
    end

    it "should render the login paragraph" do
      opts = {}
      @options = Facebooked::ConnectController::LoginOptions.new opts
      @output = @feature.facebooked_connect_login_feature({:fb_user => @fb_user})
      @output.should include( "uid=\"#{1}\"" )
    end

    it "should render the login paragraph" do
      opts = {}
      @options = Facebooked::ConnectController::LoginOptions.new opts
      @output = @feature.facebooked_connect_login_feature({:fb_user => nil})
      @output.should include( "<fb:login-button" )
    end

    it "should render the visitors paragraph" do
      opts = {}
      @options = Facebooked::ConnectController::VisitorsOptions.new opts
      @output = @feature.facebooked_connect_visitors_feature({:visitors => [@fb_user]})
      @output.should include( "uid=\"#{1}\"" )
    end

    it "should render the fan_box paragraph" do
      opts = {}
      @options = Facebooked::ConnectController::FanBoxOptions.new opts
      @output = @feature.facebooked_connect_fan_box_feature({:options => @options})
      @output.should include( "<fb:fan" )
    end

    it "should render the comments paragraph" do
      opts = {}
      @options = Facebooked::ConnectController::CommentsOptions.new opts
      @output = @feature.facebooked_connect_comments_feature({:options => @options})
      @output.should include( "<fb:comments" )
    end

    it "should render the live_stream paragraph" do
      opts = {}
      @options = Facebooked::ConnectController::LiveStreamOptions.new opts
      @output = @feature.facebooked_connect_live_stream_feature({:options => @options})
      @output.should include( "<fb:live-stream" )
    end

    it "should render the share_button paragraph" do
      opts = {}
      @options = Facebooked::ConnectController::ShareButtonOptions.new opts
      @output = @feature.facebooked_connect_share_button_feature({:options => @options})
      @output.should include( "<fb:share-button" )
    end
  end
end
