class AddPathToEggdrop < ActiveRecord::Migration
  def change
    add_column :eggdrops, :path, :string, limit: 64
  end
end
