

class Facebooked::Share::Link::Facebook < PostStream::Share::Link::Base
  def self.post_stream_link_handler_info
    {
      :name => 'Facebook Link Handler',
      :post_types => ['image']
    }
  end

  def self.setup_header(renderer)
    client = Facebooked::AdminController.facebook_client
    client.validate_fb_cookies(renderer.cookies) unless client.uid
  end

  def process_request(params, opts={})
    if self.link =~ /^http:\/\/www\.facebook\.com\//
      if self.link =~ /album.php\?(.+)/
        query = $1
        aid = nil
        id = nil
        query.split('&').each do |nv|
          name, value = nv.split('=')
          id = value if name == 'id'
          aid = value if name == 'aid'
        end

        return false unless id && aid

        client = Facebooked::AdminController.facebook_client
        if client.uid
          user = client.user
          albums = client.call 'Photos.getAlbums', 'aids' => "#{id}_#{aid}"
          return false if albums.empty?

          album = albums[0]
          return false unless album['visible'] == 'everyone'

          mini_photos = MiniFB::Photos.new client.session
          photos = mini_photos.get 'pids' => album['cover_pid']
          return false if photos.empty?

          self.options.photo = photos[0]
          self.options.link = album['link']
          self.options.uid = client.uid

          self.post.post_type = 'image'
          return true
        end
      elsif self.link =~ /photo.php\?(.+)/
        query = $1
        pid = nil
        id = nil
        query.split('&').each do |nv|
          name, value = nv.split('=')
          id = value if name == 'id'
          pid = value if name == 'pid'
        end

        return false unless id && pid

        client = Facebooked::AdminController.facebook_client
        if client.uid
          mini_photos = MiniFB::Photos.new client.session
          photos = mini_photos.get 'pids' => "#{id}_#{pid}"
          return false if photos.empty?

          self.options.photo = photos[0]
          self.options.link = photos[0]['link']
          self.options.uid = client.uid

          self.post.post_type = 'image'
          return true
        end
      end
    end

    false
  end

  def render(renderer, opts={})
    maxwidth = (opts[:maxwidth] || 340).to_i
    maxheight = opts[:maxheight] ? opts[:maxheight].to_i : nil
    title_length = (opts[:title_length] || 40).to_i

    renderer.render_to_string :partial => '/facebooked/share/link/facebook', :locals => {:post => self.post, :options => self.options, :maxwidth => maxwidth, :maxheight => maxheight, :title_length => title_length, :ajax => renderer.ajax?}
  end

  class Options < HashModel
    attributes :photo => {}, :link => nil, :uid => nil
  end
end
