class CreateEggdrops < ActiveRecord::Migration
  def change
    create_table :eggdrops do |t|
      t.integer :user_id
      t.string :password, limit: 64
      t.string :docker_id, limit: 64
      t.integer :port_users
      t.integer :port_bots
      t.integer :port_ftp

      t.timestamps
    end
    add_index :eggdrops, :user_id, unique: true
    add_index :eggdrops, :port_users, unique: true
    add_index :eggdrops, :port_bots, unique: true
    add_index :eggdrops, :port_ftp, unique: true
  end
end
