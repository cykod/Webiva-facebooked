
class Facebooked::AppController < ParagraphController

  editor_header 'Facebooked Application Paragraphs'

  editor_for :login, :name => "Login", :no_options => true
  editor_for :friend_rewards, :name => 'Friend Rewards'
  
  class LoginOptions < HashModel; end
  
  class FriendRewardsOptions < HashModel
    
    options_form(
                 )
  end
end
