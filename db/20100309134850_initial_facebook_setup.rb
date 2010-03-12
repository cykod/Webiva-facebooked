class InitialFacebookSetup < ActiveRecord::Migration
  def self.up
    create_table :facebooked_users, :force => true do |t|
      t.column :uid, :bigint
      t.integer :end_user_id
      t.string :email
      t.timestamps
    end

    add_index :facebooked_users, :uid, :unique => true
  end

  def self.down
    drop_table :facebooked_users
  end
end
