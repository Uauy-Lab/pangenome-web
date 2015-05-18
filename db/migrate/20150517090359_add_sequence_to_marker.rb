class AddSequenceToMarker < ActiveRecord::Migration
  def change
    add_column :markers, :sequence, :string
  end
end
