
class FacebookedStreamPublish
  attr_accessor :user_message, :attachment, :action_links, :target_id, :user_message_prompt, :callback, :auto_publish, :actor_id

  def initialize(name, href, description)
    @attachment = Attachment.new(name, href, description)
  end

  def add_action_link(text, href)
    @action_links ||= []
    @action_links << ActionLink.new(text, href)
  end

  class Attachment
    attr_accessor :name, :href, :caption, :description, :properties, :media, :comments_xid, :extra_data

    def initialize(name, href, description)
      @name = name
      @href = href
      @description = description
    end

    def add_property(key, value)
      @properties ||= {}

      if value.is_a?(Array)
        value = {:text => value[0], :href => value[1]}
      elsif value.is_a?(Hash)
        value = value.slice(:text, :href)
      else
        value = value.to_s
      end

      @properties[key] = value
    end

    def add_media(media)
      @media ||= []
      @media << media
    end

    def add_image(src, href)
      add_media :type => 'image', :src => src, :href => href
    end

    def add_flash(swfurl, imgurl, options={})
      add_media options.merge(:type => 'flash', :swfurl => swfurl, :imgurl => imgurl)
    end

    def add_mp3(src, options={})
      add_media options.merge(:type => 'mp3', :src => src)
    end

    def add_extra_data(key, value)
      @extra_data ||= {}
      @extra_data[key] = value
    end

    def extra_data
      @extra_data ||= {}
    end

    def to_h
      self.extra_data.merge(:name => self.name, :href => self.href, :caption => self.caption, :description => self.description, :properties => self.properties, :media => self.media, :comments_xid => self.comments_xid).delete_if { |k,v| v.nil? }
    end

    def to_hash
      self.to_h
    end
  end

  class ActionLink
    attr_accessor :text, :href

    def initialize(text, href)
      @text = text
      @href = href
    end

    def to_h
      {:text => self.text, :href => self.href}
    end

    def to_hash
      self.to_h
    end
  end
end
