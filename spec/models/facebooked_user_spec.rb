require  File.expand_path(File.dirname(__FILE__)) + "/../facebooked_spec_helper"

describe FacebookedUser do

  include FacebookedSpecHelper

  reset_domain_tables :facebooked_users, :end_users

  it "should require a uid" do
    @fb_user = FacebookedUser.new
    @fb_user.valid?
    @fb_user.should have(1).errors_on(:uid)
  end

  it "should create a new end_user" do
    myself = EndUser.new
    @facebooked_client = create_facebook_client
    @facebooked_client.validate_fb_cookies(create_valid_facebook_cookies).should be_true
    @facebooked_client.uid.should_not be_nil

    userdata = {'uid' => @facebooked_client.uid, 'email' => 'testapp-facebook-api-email@proxy.facebook.com'}
    mock_mini_fb_facebook_call("Users.getInfo", [userdata])

    assert_difference 'EndUser.count', 1 do
      @fb_user = FacebookedUser.push_facebook_user(@facebooked_client, myself)
    end

    @fb_user.id.should_not be_nil
    @fb_user.uid.should == @facebooked_client.uid.to_i
    @fb_user.end_user.should_not be_nil
    @fb_user.active?.should be_true
  end

  it "should be able to deactivate a facebook user" do
    @fb_user = FacebookedUser.create :uid => 1111222233335, :email => 'testapp-facebook-api-email@proxy.facebook.com'
    @fb_user.active?.should be_true
    @fb_user.deactivate!
    @fb_user.reload
    @fb_user.active?.should be_false
  end
end
