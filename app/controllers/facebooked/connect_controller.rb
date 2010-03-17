class Facebooked::ConnectController < ParagraphController

  editor_header 'Facebook Paragraphs'
  
  editor_for :login, :name => "Facebook Login", :feature => :facebooked_connect_login
  editor_for :visitors, :name => "Facebook Visitors", :feature => :facebooked_connect_visitors
  editor_for :user, :name => "Facebook User", :feature => :facebooked_connect_user
  editor_for :fan_box, :name => "Facebook Fan Box", :feature => :facebooked_connect_fan_box
  editor_for :comments, :name => "Facebook Comments", :feature => :facebooked_connect_comments
  editor_for :live_stream, :name => "Facebook Live Stream", :feature => :facebooked_connect_live_stream
  editor_for :share_button, :name => "Facebook Share Button", :feature => :facebooked_connect_share_button
  editor_for :stream_publish, :name => "Facebook Stream Publish", :feature => :facebooked_connect_stream_publish

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
                 fld(:css_file_id, :filemanager_file, :label => 'CSS file to use'),
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

  class CommentsOptions < HashModel
    attributes :xid => nil, :numposts => 10, :width => 550, :css_file_id => nil, :title => nil, :url => nil, :simple => false, :reverse => false, :publish_feed => false

    integer_options :numposts, :width, :css_file_id
    boolean_options :simple, :reverse, :publish_feed

    options_form(
                 fld(:xid, :text_field, :label => "Unique ID", :description => '(leave blank to use the current path)'),
                 fld(:numposts, :text_field, :label => 'Number of post to display'),
                 fld(:width, :text_field),
                 fld(:css_file_id, :filemanager_file, :label => 'CSS file to use'),
                 fld(:title, :text_field),
                 fld(:url, :text_field, :label => 'URL to the page the comment was made', :description => '(default is window.document.location.href)'),
                 fld(:simple, :check_box, :label => "Don't display rounded corners"),
                 fld(:reverse, :check_box, :label => "Reverse the ordering"),
                 fld(:publish_feed, :check_box, :label => "Publish post to user's feed")
                 )

    def validate
      errors.add(:css_file_id, 'must be a CSS file') if self.css_file && self.css_file.mime_type != 'text/css'
      errors.add(:xid, 'can contain only letters, numbers, percents(%), dashes(-) and underscores(_)') if self.xid && self.xid =~ /[^a-zA-Z0-9%_-]/
    end

    def css_file
      @css_file ||= DomainFile.find_by_id(self.css_file_id)
    end
  end

  class LiveStreamOptions < HashModel
    attributes :event_app_id => nil, :apikey => nil, :xid => 'default', :width => 450, :height => 400

    integer_options :event_app_id, :width, :height

    options_form(
                 fld(:xid, :text_field, :label => "Unique ID"),
                 fld(:width, :text_field),
                 fld(:height, :text_field)
                 )

    def validate
      errors.add(:xid, 'can contain only letters, numbers and underscores(_)') if self.xid && self.xid =~ /[^a-zA-Z0-9_]/
    end
  end

  class ShareButtonOptions < HashModel
    attributes :class_name => 'url', :url => nil, :type => 'icon_link'

    options_form(
                 fld(:url, :text_field, :label => "URL to share"),
                 fld(:type, :select, :options => :type_options)
                 )

    def self.type_options
      [['Box Count', 'box_count'], ['Button Count', 'button_count'], ['Button', 'button'], ['Icon', 'icon'], ['Icon Link', 'icon_link']]
    end
  end

  class StreamPublishOptions < HashModel
    attributes :name => nil, :href => nil, :description => nil, :media_file_id => nil, :flash_preview_file_id => nil,
      :user_message => nil, :user_message_prompt => nil, :action_text => nil, :action_href => nil, :caption => nil, :image_href => nil,
      :flash_width => nil, :flash_height => nil, :flash_expanded_width => nil, :flash_expanded_height => nil,
      :mp3_title => nil, :mp3_artist => nil, :mp3_album => nil

    validates_presence_of :href, :name, :description
    validates_urlness_of :href

    integer_options :flash_width, :flash_height, :flash_expanded_width, :flash_expanded_height, :media_file_id, :flash_preview_file_id

    options_form(
                 fld(:href, :text_field, :required => true),
                 fld(:name, :text_field, :required => true),
                 fld(:caption, :text_field),
                 fld(:description, :text_field, :required => true),
                 fld(:user_message, :text_field, :label => 'Default user message'),
                 fld(:user_message_prompt, :text_field, :label => 'Prompt'),
                 fld(:action_text, :text_field),
                 fld(:action_href, :text_field),
                 fld(:media_file_id, :filemanager_file, :label => 'Media', :description => 'image, flash or mp3', :type => 'all'),
                 fld('Image', :header),
                 fld(:image_href, :text_field, :label => 'Href', :description => 'uses main href by default'),
                 fld('Flash', :header),
                 fld(:flash_preview_file_id, :filemanager_image, :label => 'Preview'),
                 fld(:flash_width, :text_field, :label => 'Width'),
                 fld(:flash_height, :text_field, :label => 'Height'),
                 fld(:flash_expanded_width, :text_field, :label => 'Expanded width'),
                 fld(:flash_expanded_height, :text_field, :label => 'Expanded height'),
                 fld('MP3', :header),
                 fld(:mp3_title, :text_field, :label => 'Title'),
                 fld(:mp3_artist, :text_field, :label => 'Artist'),
                 fld(:mp3_album, :text_field, :label => 'Album')
                 )

    def validate
      errors.add(:action_text, 'is required') if ! self.action_text.blank? && self.action_href.blank?
      errors.add(:action_href, 'is required') if ! self.action_href.blank? && self.action_text.blank?

      if self.media_file
        if self.media_file.mime_type == 'application/x-shockwave-flash'
          errors.add(:flash_preview_file_id, 'is required') unless self.flash_preview_file
          errors.add(:flash_preview_file_id, 'must be an image') if self.flash_preview_file && ! self.flash_preview_file.mime_type.include?('image')
        elsif ! self.media_file.mime_type.include?('mp3') && ! self.media_file.mime_type.include?('image')
          errors.add(:media_file_id, 'can only be an image, mp3 or flash file')
        end
      end

    end

    def media_file
      @media_file ||= DomainFile.find_by_id(self.media_file_id)
    end

    def flash_preview_file
      @flash_preview_file ||= DomainFile.find_by_id(self.flash_preview_file_id)
    end

    def stream
      return @stream if @stream
      @stream = FacebookedStreamPublish.new(self.name, self.href, self.description)
      if ! self.action_text.blank?
        @stream.add_action_link(self.action_text, self.action_href)
      end

      @stream.user_message = self.user_message unless self.user_message.blank?
      @stream.user_message_prompt = self.user_message_prompt unless self.user_message_prompt.blank?

      @stream.attachment.caption = self.caption unless self.caption.blank?

      if self.media_file
        if self.media_file.mime_type.include?('image')
          link = self.image_href.blank? ? self.href : self.image_href
          @stream.attachment.add_image(self.media_file.full_url, link)
        elsif self.media_file.mime_type.include?('mp3')
          @stream.add_image.add_mp3(self.media_file.full_url, :title => self.mp3_title, :artist => self.mp3_artist, :album => self.mp3_album)
        elsif self.media_file.mime_type == 'application/x-shockwave-flash'
          options = {
            :width => self.flash_width,
            :height => self.flash_height,
            :expanded_width => self.flash_expanded_width,
            :expanded_height => self.flash_expanded_height
          }
          
          @stream.attachment.add_flash(self.media_file.full_url, self.flash_preview_file.full_url, options)
        end
      end

      @stream
    end
  end
end
