class AddedNames < ActiveRecord::Migration
  def self.up
    add_column :facebooked_users, :first_name, :string
    add_column :facebooked_users, :last_name, :string
  end

  def self.down
    remove_column :facebooked_users, :first_name
    remove_column :facebooked_users, :last_name
  end
end
