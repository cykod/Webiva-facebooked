require 'oauth2'

class Facebooked::OauthProvider < OauthProvider::Base
  def self.oauth_provider_handler_info
    {
      :name => 'Facebook'
    }
  end

  def authorize_url
    self.session[self.session_name] = {:redirect_uri => self.redirect_uri}
    client.web_server.authorize_url(:redirect_uri => self.redirect_uri, :scope => Facebooked::AdminController.module_options.scopes)
  end

  def access_token(params)
    self.redirect_uri = self.session[self.session_name][:redirect_uri]

    begin
      access_token = client.web_server.get_access_token(params[:code], :redirect_uri => self.redirect_uri)
      self.session[self.session_name][:token] = access_token.token
      self.session[self.session_name][:refresh_token] = access_token.refresh_token
      true
    rescue OAuth2::ErrorWithResponse, OAuth2::AccessDenied, OAuth2::HTTPError => e
      Rails.logger.error e
      false
    end
  end

  def client
    @client ||= OAuth2::Client.new(Facebooked::AdminController.module_options.app_id, Facebooked::AdminController.module_options.secret, :site => 'https://graph.facebook.com')
  end

  def facebook
    @facebook ||= OAuth2::AccessToken.new self.client, self.session[self.session_name][:token], self.session[self.session_name][:refresh_token]
  end

  def provider_id
    self.facebook_user_data[:id]
  end

  def get_profile_photo_url
    return @profile_photo_url if @profile_photo_url

    response = Net::HTTP.get_response(URI.parse("http://graph.facebook.com/#{self.provider_id}/picture?type=large"))
    case response
    when Net::HTTPRedirection
      @profile_photo_url = response['location']
    else
      nil
    end
  end

  def get_oauth_user_data
    return @oauth_user_data if @oauth_user_data

    @oauth_user_data = {
      :first_name => self.facebook_user_data[:first_name],
      :last_name => self.facebook_user_data[:last_name],
      :email => self.facebook_user_data[:email],
      :profile_photo_url => self.get_profile_photo_url
    }
  end

  protected

  def facebook_user_data
    @facebook_user_data ||= JSON.parse(self.facebook.get('/me')).symbolize_keys
  end
end
