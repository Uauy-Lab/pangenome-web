class CreateScaffolds < ActiveRecord::Migration
  def change
    create_table :scaffolds do |t|
      t.string :name
      t.integer :length
      t.timestamps null: false
    end

    create_table :scaffolds_markers, id: false do |t|
      t.belongs_to :scaffolds, index: true
      t.belongs_to :markers, index: true
    end
  end
end
