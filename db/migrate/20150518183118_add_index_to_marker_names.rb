class AddIndexToMarkerNames < ActiveRecord::Migration[6.0]
  def change
    add_index :marker_names, :alias
  end
end
