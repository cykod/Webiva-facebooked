class Facebooked::ConnectController < ParagraphController

  editor_header 'Facebook Paragraphs'
  
  editor_for :login, :name => "Facebook Connect Login", :feature => :facebooked_connect_login
  editor_for :visitors, :name => "Facebook Visitors", :feature => :facebooked_connect_visitors
  editor_for :user, :name => "Facebook User", :feature => :facebooked_connect_user

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

  class VisitorsOptions < HashModel
    attributes :visitors_to_display => 9

    integer_options :visitors_to_display, :visitors_per_row

    options_form(
                 fld(:visitors_to_display, :text_field)
                 )

  end

  class UserOptions < HashModel
    attributes :facebook_user_id => nil

    options_form(
                 fld(:facebook_user_id, :text_field, :description => '(leave blank for logged in user)')
                 )

  end
end
