class AddStatusToEggdrop < ActiveRecord::Migration
  def change
    add_column :eggdrops, :status, :integer
  end
end
