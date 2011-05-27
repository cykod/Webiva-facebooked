
class Facebooked::AppController < ParagraphController

  editor_header 'Facebooked Application Paragraphs'

  editor_for :login, :name => "Login", :no_options => true
  editor_for :friend_rewards, :name => 'Friend Rewards', :feature => :facebooked_app_friend_rewards
  editor_for :friends, :name => 'Friends', :no_options => true, :feature => :facebooked_app_friends
  
  class LoginOptions < HashModel; end
  class FriendsOptions < HashModel; end
  
  class FriendRewardsOptions < HashModel
    include HandlerActions

    attributes :rewards_handler => nil, :data => {}
    
    options_form(
                 fld(:rewards_handler, :select, :options => :rewards_handler_options)
                 )
    
    def rewards_handler_options
      [['--Select rewards handler--', nil]] + get_handler_options(:facebooked, :rewards)
    end
    
    def validate
      if self.handler
        self.errors.add(:data, 'is invalid') unless self.handler.valid?
      end
    end

    def handler_info
      @handler_info ||= get_handler_info(:facebooked, :rewards, self.rewards_handler) if self.rewards_handler
    end
    
    def handler_class
      self.handler_info[:class] if self.handler_info
    end
    
    def create_handler
      if self.handler_class
        h = self.handler_class.new self.data
        h.format_data
        h
      else
        nil
      end
    end

    def handler
      @handler ||= self.create_handler
    end
    
    def reward(oauth_user, friends)
      self.handler.reward oauth_user, friends if self.handler
    end
    
    def data=(hsh)
      @data = hsh.to_hash.symbolize_keys
    end

    def options_partial
      '/facebooked/app/rewards'
    end

    def features(c, data, base='reward')
      return unless self.handler && self.handler.respond_to?(:features)
      self.handler.features(c, data, base)
    end
  end
end
