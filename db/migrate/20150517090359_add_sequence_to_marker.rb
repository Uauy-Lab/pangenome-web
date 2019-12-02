class AddSequenceToMarker < ActiveRecord::Migration[6.0]
  def change
    add_column :markers, :sequence, :string
  end
end
