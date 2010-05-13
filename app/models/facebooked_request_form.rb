
class FacebookedRequestForm
  attr_accessor :type, :message, :invite, :action, :method, :choices, :selector

  def initialize
    @invite = true
    @method = 'GET'
    @selector = MultiFriendSelector.new
    @choices = []
  end

  def add_choice(url, label)
    @choices << ReqChoice.new(url, label)
  end

  def to_h
    {:type => self.type, :invite => self.invite ? 'true' : 'false', :action => self.action, :method => self.method}.delete_if { |k,v| v.nil? }
  end

  def to_hash
    self.to_h
  end

  class MultiFriendSelector
    attr_accessor :actiontext, :showborder, :rows, :max, :exclude_ids, :bypass, :email_invite, :cols,
      :condensed, :unselected_rows, :selected_rows

    def width(canvas=false)
      # if not on a facebook canvas page the iframe will be too small to display the popup
      unless canvas
        return 625
      end

      if self.condensed
        200
      else
        case self.cols
        when 2
          368
        when 3
          466
        else
          740
        end
      end
    end

    def to_h
      if self.condensed
        {:condensed => 'true', :max => self.max, :exclude_ids => self.exclude_ids, :unselected_rows => self.unselected_rows, :selected_rows => self.selected_rows}.delete_if { |k,v| v.nil? }
      else
        {:actiontext => self.actiontext, :showborder => self.showborder, :rows => self.rows, :max => self.max, :exclude_ids => self.exclude_ids, :bypass => self.bypass, :email_invite => self.email_invite, :cols => self.cols}.delete_if { |k,v| v.nil? }
      end
    end

    def to_hash
      self.to_h
    end
  end

  class ReqChoice
    attr_accessor :url, :label

    def initialize(url, label)
      @url = url
      @label = label
    end

    def to_h
      {:url => self.url, :label => self.label}
    end

    def to_hash
      self.to_h
    end
  end
end
