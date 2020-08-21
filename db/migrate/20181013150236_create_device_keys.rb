class CreateDeviceKeys < ActiveRecord::Migration[5.2]
  def change
    create_table :device_keys do |t|
      t.string :public_key, limit: 5000
      t.datetime :expired_at
      t.boolean :active, default: true
      t.timestamps
    end
  end
end
