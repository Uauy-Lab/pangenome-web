class AddAlignIdToAlignments < ActiveRecord::Migration[6.0]
  def change
    add_column :alignments, :align_id, :integer
  end
end
