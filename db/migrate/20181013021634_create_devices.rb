class CreateDevices < ActiveRecord::Migration[5.2]
  def change
    create_table :devices do |t|
      t.string :name
      t.integer :device_key_id
      t.integer :organization_id
      t.integer :user_id
      t.string :code
      t.timestamp :code_expired_at
      t.timestamp :code_used_at
      t.string :access_token
      t.datetime :access_token_expired_at

      t.timestamps
    end
    add_index :devices, :name, unique: true
  end
end
