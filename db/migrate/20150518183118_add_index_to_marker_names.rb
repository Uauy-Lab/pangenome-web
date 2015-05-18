class AddIndexToMarkerNames < ActiveRecord::Migration
  def change
    add_index :marker_names, :alias
  end
end
