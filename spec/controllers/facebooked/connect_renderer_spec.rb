require  File.expand_path(File.dirname(__FILE__)) + '/../../facebooked_spec_helper'

describe Facebooked::ConnectRenderer, :type => :controller do
  include FacebookedSpecHelper
  controller_name :page
  
  integrate_views

  reset_domain_tables :end_user, :facebooked_users

  def generate_page_renderer(paragraph, options={}, inputs={})
    @rnd = build_renderer('/page', '/facebooked/connect/' + paragraph, options, inputs)
  end

  describe "Facebook client tests" do
    before(:each) do
      @facebooked_client = create_facebook_client
      Facebooked::AdminController.should_receive(:facebook_client).and_return(@facebook_client)
    end

    it "should be able to render login paragraph" do
      @rnd = generate_page_renderer('login')
      renderer_get @rnd
    end

    it "should be able to create an end user if a facebook user has connected to the site" do
      @myself = EndUser.new
      controller.should_receive('myself').at_least(:once).and_return(@myself)

      uid = 1111222233335

      @rnd = generate_page_renderer('login')
      cookies = create_valid_facebook_cookies(uid)
      controller.stub!(:cookies).and_return(cookies)

      userdata = {'uid' => uid, 'email' => 'testapp-facebook-api-email@proxy.facebook.com'}
      mock_mini_fb_facebook_call("Users.getInfo", [userdata])

      assert_difference 'EndUser.count', 1 do
        renderer_get @rnd
      end
    end

    it "should be able to logout" do
      @rnd = generate_page_renderer('login')
      @rnd.should_receive(:process_logout)
      renderer_get @rnd, :cms_logout => 1
    end

    it "should be able to render user paragraph" do
      @rnd = generate_page_renderer('user')
      renderer_get @rnd
    end

    it "should be able to render user paragraph with facebook user" do
      mock_user
      uid = 1111222233335
      @fb_user = FacebookedUser.create :uid => uid, :email => 'testapp-facebook-api-email@proxy.facebook.com', :end_user_id => @myself.id
      cookies = create_valid_facebook_cookies(uid)
      controller.stub!(:cookies).and_return(cookies)

      @rnd = generate_page_renderer('user')
      FacebookedUser.should_receive(:find_by_uid).with(uid.to_s).and_return(@fb_user)
      renderer_get @rnd
    end

    describe "Logged into Facebook User tests" do
      before(:each) do
        mock_user
        uid = 1111222233335
        @fb_user = FacebookedUser.create :uid => uid, :email => 'testapp-facebook-api-email@proxy.facebook.com', :end_user_id => @myself.id
        cookies = create_valid_facebook_cookies(uid)
        controller.stub!(:cookies).and_return(cookies)
      end

      it "should render fan_box" do
        @rnd = generate_page_renderer('fan_box')
        renderer_get @rnd
      end

      it "should render comments" do
        @rnd = generate_page_renderer('comments')
        renderer_get @rnd
      end

      it "should render live_stream" do
        @rnd = generate_page_renderer('live_stream')
        renderer_get @rnd
      end

      it "should render share_button" do
        @rnd = generate_page_renderer('share_button')
        renderer_get @rnd
      end
    end
  end

  it "should render lastest visitors paragraph" do
    @rnd = generate_page_renderer('visitors')
    renderer_get @rnd
  end

end
