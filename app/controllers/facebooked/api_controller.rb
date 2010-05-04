
class Facebooked::ApiController < ApplicationController
  def albums
    return render :inline => 'false' unless self.provider.token

    response = JSON.parse(self.provider.get('/me/albums', {:fields => 'id,photos,privacy,count,link,name,from'}))
    return render :inline => '[]' unless response['data']

    albums = response['data'].collect do |album|
      if album['privacy'] == 'everyone' && album['count']
        {
          :id => album['id'],
          :name => album['name'],
          :link => album['link'],
          :count => album['count'],
          :picture => album['photos']['data'][0]['source'],
          :width => album['photos']['data'][0]['width'],
          :height => album['photos']['data'][0]['height'],
          :author_name => album['from']['name'],
          :author_id => album['from']['id'],
        }
      else
        nil
      end
    end.compact

    return render :inline => albums.to_json
  end

  protected
  def provider
    @provider ||= Facebooked::OauthProvider.new session
  end

  def facebook
    @facebook ||= self.provider.facebook
  end
end

