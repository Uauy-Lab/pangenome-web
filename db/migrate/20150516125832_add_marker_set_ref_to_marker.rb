class AddMarkerSetRefToMarker < ActiveRecord::Migration
  def change
   # add_column :markers, :marker, :marker_set
    add_reference :markers, :marker_set, index: true, foreign_key: true
  end
end
