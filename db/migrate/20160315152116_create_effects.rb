class CreateEffects < ActiveRecord::Migration
  def change
    create_table :effects do |t|
      t.references :snp, index:true
      t.references :feature, index:true
      t.references :effect_type
      t.integer :cdna_position
      t.integer :cds_position
      t.string :amino_acids,  limit: 8
      t.string :codons,  limit: 7
      t.float :sift_score

      t.timestamps null: false
    end
  end
end
