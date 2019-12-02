class CreateLibraries < ActiveRecord::Migration[6.0]
  def change
    create_table :libraries do |t|
      t.string :name
      t.string :description
      t.references :mutant_line, index: true

      t.timestamps null: false
    end
    add_foreign_key :libraries, :mutant_lines
  end
end
