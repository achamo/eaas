class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.integer :eggdrop_id
      t.text :data

      t.timestamps
    end
  end
end
