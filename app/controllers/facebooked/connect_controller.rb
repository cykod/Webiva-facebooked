class Facebooked::ConnectController < ParagraphController

  editor_header 'Facebook Paragraphs'
  
  editor_for :login, :name => "Facebook Connect Login", :feature => :facebooked_connect_login
  editor_for :visitors, :name => "Facebook Visitors", :feature => :facebooked_connect_visitors
  editor_for :user, :name => "Facebook User", :feature => :facebooked_connect_user
  editor_for :fan_box, :name => "Facebook Fan Box", :feature => :facebooked_connect_fan_box

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

  class FanBoxOptions < HashModel
    attributes :profile_id => nil, :name => nil, :stream => true, :connections => 10, :width => 300, :height => 554, :css_file_id => nil, :logobar => true

    integer_options :profile_id, :connections, :width, :height, :css_file_id
    boolean_options :stream, :logobar

    options_form(
                 fld(:profile_id, :text_field, :label => 'Profile ID or App ID', :description => 'The ID of the Page associated with the Fan Box.'),
                 fld(:name, :text_field, :label => "Page's name", :description => "Page's name or username."),
                 fld(:stream, :check_box, :label => 'Display stream stories'),
                 fld(:connections, :text_field, :label => 'Number of users to display'),
                 fld(:width, :text_field),
                 fld(:height, :text_field),
                 fld(:css_file_id, :filemanager_file, :label => 'CSS file to use.'),
                 fld(:logobar, :check_box, :label => 'Display Facebook logo bar')
                 )

    def validate
      if self.profile_id.blank? && self.name.blank?
        errors.add(:profile_id, 'must set either profile_id or name')
        errors.add(:name, 'must set either profile_id or name')
      elsif ! self.profile_id.blank? && ! self.name.blank?
        errors.add(:profile_id, 'must set either profile_id or name not both')
        errors.add(:name, 'must set either profile_id or name not both')
      end

      errors.add(:connections, 'can not be greater than 100') if self.connections > 100
      errors.add(:width, 'too small must be at least 200') if self.width < 200
      errors.add(:height, 'too small must be at least 64') if self.height < 64

      errors.add(:css_file_id, 'must be a CSS file') if self.css_file && self.css_file.mime_type != 'text/css'
    end

    def css_file
      @css_file ||= DomainFile.find_by_id(self.css_file_id)
    end
  end
end
