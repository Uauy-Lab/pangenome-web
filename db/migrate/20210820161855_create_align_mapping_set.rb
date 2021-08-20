class CreateAlignMappingSet < ActiveRecord::Migration[6.1]
  def change
    create_table :align_mapping_sets do |t|
      t.string :name
      t.string :description
      t.integer :mapping_count

      t.timestamps
    end
  end
end
