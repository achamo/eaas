class CreatePools < ActiveRecord::Migration
  def change
    create_table :pools do |t|
      t.integer :port_users
      t.integer :port_bots
      t.integer :port_ftp

      t.timestamps
    end
  end
end
