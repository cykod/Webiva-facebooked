
class Facebooked::AppFeature < ParagraphFeature
  feature :facebooked_app_friend_rewards, :default_feature => <<-FEATURE
  <cms:friends>
  <ul>
    <cms:friend>
    <li><cms:image/> <cms:name/></li>
    </cms:friend>
  </ul>
  </cms:friends>
  FEATURE

  def facebooked_app_friend_rewards_feature(data)
    webiva_feature(:facebooked_app_friend_rewards,data) do |c|
      c.loop_tag('friend') { |t| data[:friends] }
      c.h_tag('friend:name') { |t| t.locals.friend.name }
      c.image_tag('friend:image') { |t| t.locals.friend.end_user.image if t.locals.friend.end_user }
    end
  end
end
