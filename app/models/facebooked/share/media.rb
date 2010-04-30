
class Facebooked::Share::Media < PostStream::Share::Base

  def self.post_stream_share_handler_info
    {
      :name => 'Facebook'
    }
  end

  def self.setup_header(renderer)
    unless renderer.ajax?
      renderer.require_js('builder')
      renderer.require_js('/components/facebooked/javascript/album.js')
      renderer.require_css('/components/facebooked/stylesheets/album.css')
    end
  end

  def valid_params
    [:album_id]
  end

  def valid?
    is_valid = super
    self.post.errors.add_to_base('Album is not selected') if self.options.errors[:album_id]
    is_valid
  end

  def render_form_elements(renderer, form, opts={})
    output = form.hidden_field(:album_id) + '<div class="facebook_album_frame"><div id="facebook_albums"></div><hr class="separator"/></div>'
    output << '<script>FacebookAlbumSelector.ready();</script>' if renderer.ajax?
    output
  end

  def process_request(renderer, params, opts={})
    if self.options.album_id
      oauth_provider = Facebooked::OauthProvider.new renderer.session
      facebook = oauth_provider.facebook
      begin
        self.options.data = JSON.parse(facebook.get("/#{self.options.album_id}", :fields => 'picture')).symbolize_keys
        self.options.author = JSON.parse(facebook.get("/me", :fields => 'id,name,link')).symbolize_keys
      rescue OAuth2::HTTPError => e
        Rails.logger.error e
      end

      self.post.link = self.options.data[:link]
      true
    else
      nil
    end
  end

  def render(renderer, opts={})
    maxwidth = (opts[:maxwidth] || 340).to_i
    maxheight = opts[:maxheight] ? opts[:maxheight].to_i : nil
    title_length = (opts[:title_length] || 40).to_i
    renderer.render_to_string :partial => '/facebooked/share/media', :locals => {:post => self.post, :options => self.options, :maxwidth => maxwidth, :maxheight => maxheight, :title_length => title_length}
  end

  def render_button(opts={})
    text = opts['title'] || self.title
    handler = self.class.to_s.underscore
    content_tag(:a, text, {:href => 'javascript:void(0);', :onclick => "PostStreamForm.share('#{self.type}', '#{handler}'); FacebookAlbumSelector.init('facebook_albums', 'stream_post_facebook_album_id');"})
  end

  def preview_image_url
    self.options.data[:picture]
  end

  class Options < HashModel
    attributes :album_id => nil, :data => {}, :author => {}

    validates_presence_of :album_id
  end
end
