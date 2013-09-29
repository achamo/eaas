class AddUsedToPool < ActiveRecord::Migration
  def change
    add_column :pools, :used, :boolean
  end
end
