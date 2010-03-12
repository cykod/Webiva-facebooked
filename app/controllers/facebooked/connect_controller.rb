class Facebooked::ConnectController < ParagraphController

  editor_header 'Facebook Paragraphs'
  
  editor_for :login, :name => "Facebook Connect Login", :feature => :facebooked_connect_login

  class LoginOptions < HashModel
    attributes :destination_page_id => nil, :access_token_id => nil, :forward_login => 'yes', :edit_account_page_id => nil

    page_options :destination_page_id

    options_form(
                 fld(:destination_page_id, :select, :options => :page_options, :label => 'Destination Page'),
                 fld(:forward_login, :radio_buttons, :options => :forward_login_options, :description => 'If users were locked out of a previous, forward them back to that page.'),
                 fld(:access_token_id, :select, :options => :access_token_options, :label => 'Access Token'),
                 fld(:edit_account_page_id, :select, :options => :page_options, :label => 'Edit Account Page')                 
                 )

    def self.access_token_options
      [['--Select Access Token--', nil]] + AccessToken.user_token_options
    end

    def self.page_options
      [[ '--Stay on Same Page--'.t, nil ]] + SiteNode.page_options()
    end

    def self.forward_login_options
      [['Yes','yes'], ['No','no']]
    end
  end

end
