class Facebooked::ConnectFeature < ParagraphFeature


  feature :facebooked_connect_login, :default_feature => <<-FEATURE
    <cms:login_button/>
    <cms:logged_in>you are logged in</cms:logged_in>
  FEATURE
  

  def facebooked_connect_login_feature(data)
    webiva_feature(:facebooked_connect_login,data) do |c|
      c.define_tag('login_button') do |t|
        content_tag('fb:login-button', t.expand || 'Connect with Facebook', {'v' => 2, 'size' => 'medium', 'onlogin' => data[:onlogin]})
      end

      c.expansion_tag('logged_in') { |t| data[:logged_in] }
    end
  end


end
