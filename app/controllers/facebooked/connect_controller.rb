class Facebooked::ConnectController < ParagraphController

  editor_header 'Facebook Paragraphs'
  
  editor_for :login, :name => "Facebook Connect Login", :feature => :facebooked_connect_login

  class LoginOptions < HashModel
    attributes :auto_register => true, :onlogin_redirect_id => nil

    page_options :onlogin_redirect_id

    options_form(
                 fld(:auto_register, :check_box),
                 fld(:onlogin_redirect_id, :select, :options => :page_options, :label => 'Onlogin Redirect')
                 )

    def self.page_options
      [[ '--Stay on Same Page--'.t, nil ]] + SiteNode.page_options()
    end
  end

end
