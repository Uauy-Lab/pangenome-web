class CreateChromosomes < ActiveRecord::Migration[6.0]
  def change
    create_table :chromosomes do |t|
      t.string :name
      t.belongs_to :species
      t.timestamps null: false
    end
  end
end
