class Facebooked::ConnectController < ParagraphController

  editor_header 'Facebook Connect Paragraphs'
  
  editor_for :request_form, :name => "Facebook Request Form", :feature => :facebooked_connect_request_form

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
end
