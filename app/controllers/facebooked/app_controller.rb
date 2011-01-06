
class Facebooked::AppController < ParagraphController

  editor_header 'Facebooked Application Paragraphs'

  editor_for :login, :name => "Login", :no_options => true

  class LoginOptions < HashModel; end
end
