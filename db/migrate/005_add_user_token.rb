class AddUserToken < ActiveRecord::Migration
  def change
    create_table :user_tokens do |t|
      t.string :token
      t.integer :user_id
      t.datetime :expires
      t.timestamps
    end
  end
end
