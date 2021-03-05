class CreateScoreTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :score_types do |t|
      t.string :name
      t.text :description
      t.integer :mantisa

      t.timestamps
    end
    add_index(:score_types, :name)
  end

end
