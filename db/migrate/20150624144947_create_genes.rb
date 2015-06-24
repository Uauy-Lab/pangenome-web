class CreateGenes < ActiveRecord::Migration
  def change
    create_table :genes do |t|
      t.string :name
      t.string :cdna
      t.string :possition
      t.string :gene
      t.string :transcript
      t.references :gene_set, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :genes, :name
    add_index :genes, :gene
    add_index :genes, :transcript
  end
end
