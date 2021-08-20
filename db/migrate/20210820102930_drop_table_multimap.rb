class DropTableMultimap < ActiveRecord::Migration[6.1]
  def change
    drop_table :multi_maps
  end
end
