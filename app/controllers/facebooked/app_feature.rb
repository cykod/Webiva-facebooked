
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

      c.expansion_tag('reward') { |t| data[:options].handler }
      data[:options].features(c, data, 'reward')
    end
  end

  feature :facebooked_app_friends, :default_feature => <<-FEATURE
  <cms:friends>
  <ul>
    <cms:friend>
    <li><cms:image/> <cms:name/></li>
    </cms:friend>
  </ul>
  </cms:friends>
  FEATURE

  def facebooked_app_friends_feature(data)
    webiva_feature(:facebooked_app_friends,data) do |c|
      c.loop_tag('friend') { |t| data[:friends] }
      c.h_tag('friend:name') { |t| t.locals.friend.name }
      c.image_tag('friend:image') { |t| t.locals.friend.end_user.image if t.locals.friend.end_user }
      c.link_tag('friend:profile') do |t| 
        if data[:profile_entries]
          profile = data[:profile_entries][t.locals.friend.end_user_id]
          profile.content_node.link if profile
        end
      end
    end
  end
end
