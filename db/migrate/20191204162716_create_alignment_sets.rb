class CreateAlignmentSets < ActiveRecord::Migration[6.0]
  def change
    create_table :alignment_sets do |t|
      t.string :name, index: true
      t.string :description
      t.integer :alignments_count
      t.timestamps
    end

  end
end
