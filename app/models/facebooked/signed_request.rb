require 'base64'
require 'openssl'

class Facebooked::SignedRequest
  attr_reader :data

  def initialize(signed_request)
    @sig, @payload = signed_request.split '.'
    @sig = Facebooked::SignedRequest.base64_url_decode @sig
    @data = JSON.parse Facebooked::SignedRequest.base64_url_decode(@payload)
  end

  def valid?
    @data['algorithm'].to_s.upcase == 'HMAC-SHA256' && OpenSSL::HMAC.hexdigest('sha256', self.secret, @payload) == Facebooked::SignedRequest.str_to_hex(@sig)
  end

  def self.base64_url_decode(str)
    str = str.gsub('-', '+').gsub('_', '/')
    padding = 4 - (str.size % 4)
    str += '=' * padding if padding < 4
    Base64.decode64 str
  end

  def self.str_to_hex(str)
    (0..(str.size-1)).to_a.map do |i|
      number = str[i].to_s(16)
      (str[i] < 16) ? ('0' + number) : number
    end.join
  end

  def secret
    Facebooked::AdminController.module_options.secret
  end

  def oauth_token
    @data['oauth_token']
  end

  def user_id
    @data['user_id']
  end

  def expires
    @data['expires']
  end

  def expires_at
    @expires_at ||= Time.at self.expires
  end

  def issued
    @data['issued_at']
  end

  def issued_at
    @issued_at ||= Time.at self.issued
  end

  def locale
    @data['user']['locale'] if @data['user']
  end

  def country
    @data['user']['country'] if @data['user']
  end
end
