
class Facebooked::Feed
  class Post < HashModel
    attributes :post_id => nil, :likes => nil, :from => nil, :to => nil,
      :message => nil, :picture => nil, :link => nil, :name => nil, :caption => nil,
      :description => nil, :source => nil, :icon => nil, :attribution => nil, :actions => nil, :privacy => 'EVERYONE',
      :created_time => nil, :updated_time => nil, :targeting => nil

    validates_presence_of :message

    @@privacy_options = %w(EVERYONE CUSTOM ALL_FRIENDS NETWORKS_FRIENDS FRIENDS_OF_FRIENDS).map { |o| [o.titleize, o] }
    def self.privacy_options
      @@privacy_options
    end

    def add_action(name, link)
      self.actions ||= []
      self.actions << {'name' => name, 'link' => link}
    end

    def publish(provider)
      headers = {}
      params = {
        :message => self.message,
        :link => self.link,
        :picture => self.picture,
        :name => self.name,
        :caption => self.caption,
        :description => self.description,
        :source => self.source,
        :actions => self.actions ? self.actions.to_json : nil,
        :privacy => {'value' => self.privacy}.to_json,
        :targeting => self.targeting ? self.targeting.to_json : nil
      }.reject { |k, v| v.nil? }

      @result = provider.post '/me/feed', params, headers
      @result['id'].blank? ? false : true
    end

    def result
      @result
    end
  end
end
