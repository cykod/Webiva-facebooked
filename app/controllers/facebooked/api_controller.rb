
class Facebooked::ApiController < ApplicationController
  def albums
    return render :inline => 'false' unless self.provider.token

    albums = JSON.parse(self.provider.get('/me/albums'))['data'].collect do |album|
      data = JSON.parse(self.provider.get("/#{album['id'].to_s}", {:fields => 'picture'}))
      if data['privacy'] == 'everyone'
        data['type'] = 'album'
        data
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

