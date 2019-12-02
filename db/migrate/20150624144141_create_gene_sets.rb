class CreateGeneSets < ActiveRecord::Migration[6.0]
  def change
    create_table :gene_sets do |t|
      t.string :name
      t.text :description

      t.timestamps null: false
    end
    add_index :gene_sets, :name
  end
end
