class CreateMutationConsequences < ActiveRecord::Migration
  def change
    create_table :mutation_consequences do |t|
      t.string :name
      t.text :description

      t.timestamps null: false
    end
    add_index :mutation_consequences, :name
  end
end
