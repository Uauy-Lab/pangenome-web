class CreateAlignments < ActiveRecord::Migration[6.0]
  def change
    create_table :alignments do |t|
      t.references :alignment_set, foreign_key: true
      t.references :region, foreign_key: true
      t.references :feature_type, foreign_key: true
      t.references :assembly, foreign_key: true
      t.float :pident
      t.integer :length

      t.timestamps
    end
  end
end
