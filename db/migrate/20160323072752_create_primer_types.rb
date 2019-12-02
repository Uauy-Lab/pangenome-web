class CreatePrimerTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :primer_types do |t|
      t.string :name
      t.string :description

      t.timestamps null: false
    end
  end
end
