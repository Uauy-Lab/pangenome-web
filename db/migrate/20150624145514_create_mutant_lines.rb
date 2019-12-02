class CreateMutantLines < ActiveRecord::Migration[6.0]
  def change
    create_table :mutant_lines do |t|
      t.string :name
      t.text :description

      t.timestamps null: false
    end
    add_index :mutant_lines, :name
  end
end
