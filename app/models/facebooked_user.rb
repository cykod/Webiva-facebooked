
class FacebookedUser < DomainModel

  belongs_to :end_user
  validates_uniqueness_of :uid

  def self.push_facebook_user(client, myself, options={})
    return nil unless client.uid

    fb_user = self.find_by_uid(client.uid)
    if fb_user.nil?
      user = client.session.user
      return nil unless user && user.uid

      if myself.id.nil?
        user_options = {:registered => true, :activated => true, :hashed_password => 'invalid'}.merge(options)
        myself = EndUser.push_target(user['email'], user_options)
      end

      fb_user = self.create :uid => client.uid, :email => user['email'], :end_user_id => myself.id
    elsif ! fb_user.active?
      user = client.session.user
      return nil unless user && user.uid

      fb_user.update_attributes :email => user['email']
    end

    fb_user
  end

  def self.facebook_end_user_data(client)
    user = client.session.user
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

  def deactivate
    self.email = nil
    self.save
  end
end
