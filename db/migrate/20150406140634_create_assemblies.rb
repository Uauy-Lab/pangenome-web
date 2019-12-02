class CreateAssemblies < ActiveRecord::Migration[6.0]
  def change
    create_table :assemblies do |t|
      t.string :name
      t.string :description
      t.string :version
      t.timestamps null: false
    end
  end
end
