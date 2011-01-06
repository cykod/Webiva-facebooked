class Facebooked::ConnectController < ParagraphController

  editor_header 'Facebook Connect Paragraphs'
  
  editor_for :request_form, :name => "Facebook Request Form", :feature => :facebooked_connect_request_form
  editor_for :publish, :name => "Facebook Publish Post", :feature => :facebooked_connect_publish

  class RequestFormOptions < HashModel
    attributes :message => nil, :skip_page_id => nil, :type => 'invite', :choice_text => nil, :choice_page_id => nil,
      :condensed => false, :actiontext => 'Select the friends you want to invite.',
      :showborder => false, :rows => 5, :bypass => 'skip', :email_invite => true, :cols => 5,
      :unselected_rows => 6, :selected_rows => 5

    validates_presence_of :message, :skip_page_id, :type, :choice_text, :choice_page_id

    integer_options :rows, :cols, :unselected_rows, :selected_rows
    page_options :skip_page_id, :choice_page_id
    boolean_options :condensed, :email_invite, :showborder

    options_form(
                 fld(:type, :text_field, :description => 'corresponds to the word on the user\'s home page', :required => true),
                 fld(:message, :text_area, :rows => 5, :required => true),
                 fld(:skip_page_id, :select, :options => :page_options, :required => true),
                 fld(:choice_text, :text_field, :required => true),
                 fld(:choice_page_id, :select, :options => :page_options, :required => true),
                 fld(:condensed, :check_box, :description => 'use condensed version of friend multiple select'),
                 fld('Mulit-select options', :header),
                 fld(:actiontext, :text_field, :label => 'Instructions'),
                 fld(:rows, :select, :options => (3..10).to_a),
                 fld(:cols, :select, :options => [2, 3, 5]),
                 fld(:showborder, :check_box, :label => 'Show border'),
                 fld(:email_invite, :check_box, :description => 'Allow the user to specify email addresses'),
                 fld(:bypass, :select, :options => [['Skip This Step', 'step'], ['Cancel', 'cancel'], ['Skip', 'skip']], :label => 'By pass button label'),
                 fld('Mulit-select options (condensed)', :header),
                 fld(:unselected_rows, :select, :options => (4..15).to_a),
                 fld(:selected_rows, :select, :options => [0] + (5..15).to_a)
                 )

    def validate
      if ! self.condensed
        errors.add(:actiontext, 'is required') if self.actiontext.blank?
      end
    end

    def self.page_options
      SiteNode.page_options()
    end

    def request_form
      return @request_form if @request_form
      @request_form = FacebookedRequestForm.new
      @request_form.type = self.type
      @request_form.message = self.message
      @request_form.action = Configuration.domain_link(self.skip_page_url) if self.skip_page_id
      @request_form.add_choice(Configuration.domain_link(self.choice_page_url), self.choice_text) if self.choice_page_id
      @request_form.selector.condensed = self.condensed
      @request_form.selector.actiontext = self.actiontext
      @request_form.selector.showborder = self.showborder
      @request_form.selector.rows = self.rows
      @request_form.selector.bypass = self.bypass
      @request_form.selector.email_invite = self.email_invite
      @request_form.selector.cols = self.cols
      @request_form.selector.unselected_rows = self.unselected_rows
      @request_form.selector.selected_rows = self.selected_rows
      @request_form
    end
  end

  class PublishOptions < HashModel
    attributes :message => nil, :link => nil, :picture_file_id => nil, :name => nil, :caption => nil, 
      :description => nil, :source_url => nil, :source_file_id => nil, :action_name => nil, :action_url => nil,
      :privacy => 'EVERYONE', :success_page_id => nil

    domain_file_options :picture_file_id, :source_file_id
    page_options :success_page_id

    options_form(
                 fld(:message, :text_field, :description => "Default message to post"),
                 fld(:privacy, :select, :options => :privacy_options),
                 fld(:picture_file_id, :filemanager_image),
                 fld(:success_page_id, :page_selector),
                 fld('Link Options [optional]', :header),
                 fld(:link, :text_field, :description => 'Link to share'),
                 fld(:name, :text_field, :label => 'Link name'),
                 fld(:caption, :text_field, :label => 'Link caption'),
                 fld(:description, :text_field, :label => 'Link description'),
                 fld('Source Options [optional]', :header),
                 fld(:source_url, :text_field, :description => 'A URL to a Flash movie or video file to be embedded within the post.'),
                 fld(:source_file_id, :filemanager_file, :description => 'A Flash movie of video file to share'),
                 fld('Action Link [optional]', :header),
                 fld(:action_name, :text_field),
                 fld(:action_url, :text_field)
                 )

    def privacy_options
      Facebooked::Feed::Post.privacy_options
    end

    def source
      self.source_file ? self.source_file.url : self.source_url
    end

    def picture
      self.picture_file_full_url
    end

    def post
      return @post if @post
      @post = Facebooked::Feed::Post.new self.to_hash.slice(:message, :link, :name, :caption, :description, :privacy)
      @post.source = self.source
      @post.picture = self.picture
      @post.add_action(self.action_name, self.action_url) unless self.action_name.blank? || self.action_url.blank?
      @post
    end
  end
end
