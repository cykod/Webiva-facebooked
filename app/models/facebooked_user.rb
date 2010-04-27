
class FacebookedUser < DomainModel

  cached_content

  has_end_user :end_user_id, :name_column => :name
  validates_presence_of :uid
  validates_uniqueness_of :uid

  named_scope :active_users, :conditions => 'email IS NOT NULL'

  def self.push_facebook_user(client, myself, options={})
    return nil unless client.uid
    return nil if myself.editor?

    fb_user = self.find_by_uid(client.uid)

    if fb_user.nil? || ! fb_user.active?
      user = client.user
      return nil unless user

      myself = self.push_end_user(client, myself, options)
      return nil unless myself

      if fb_user
        fb_user.update_attributes :email => user['email'], :end_user_id => myself.id, :first_name => user['first_name'], :last_name => user['last_name']
      else
        fb_user = self.create :uid => client.uid, :email => user['email'], :end_user_id => myself.id, :first_name => user['first_name'], :last_name => user['last_name']
      end
    end

    fb_user
  end

  def self.push_end_user(client, myself, options)
    if myself.id.nil?
      user = client.user

      myself = EndUser.find_by_email(user['email'])
      return nil if myself && myself.editor?

      if myself.nil? || ! myself.registered?
        user_options = {:registered => true, :activated => true, :hashed_password => 'invalid'}.merge(options)
        myself = EndUser.push_target(user['email'], user_options)
      end
    end

    myself
  end

  def self.facebook_end_user_data(client)
    user = client.user
    data = {
      :first_name => user['first_name'],
      :last_name => user['last_name'],
      :dob => nil,
      :gender => nil,
      :language => user['locale'] ? user['locale'][0..1] : nil,
      :city => nil,
      :state => nil,
      :country => nil,
      :zip => nil,
      :time_zone => nil
    }

    if user['birthday_date']
      begin
        data[:dob] = Time.parse(user['birthday_date'])
      rescue
      end
    end

    if user['sex'] == 'male'
      data[:gender] = 'm'
    elsif user['sex'] == 'female'
      data[:gender] = 'f'
    end

    if user['current_location'].is_a?(Hash)
      data[:city] = user['current_location']['city']
      data[:state] = user['current_location']['state']
      data[:country] = user['current_location']['country']
      data[:zip] = user['current_location']['zip']
    end

    if user['timezone']
      timezone = ActiveSupport::TimeZone[(user['timezone'].to_i)]
      data[:time_zone] = timezone.name
    end

    data
  end

  def active?
    ! self.email.blank?
  end

  def deactivate!
    self.email = nil
    self.save
  end

  def authorize
  end

  def name
    if self.first_name && self.last_name
      "#{self.first_name} #{self.last_name}"
    elsif self.first_name
      self.first_name
    end
  end

  def update_data(client, options={})
    end_user_data = FacebookedUser.facebook_end_user_data(client)

    can_update_end_user = false
    if (self.end_user.first_name.blank? || self.end_user.first_name == self.first_name) &&
        (self.end_user.last_name.blank? || self.end_user.last_name == self.last_name)
      can_update_end_user = true
    end

    self.first_name = end_user_data[:first_name]
    self.last_name = end_user_data[:last_name]
    self.save

    if can_update_end_user
      self.end_user.first_name = self.first_name
      self.end_user.last_name = self.last_name
      self.end_user.save
    end
  end
end
