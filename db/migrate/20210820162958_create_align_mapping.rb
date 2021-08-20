class CreateAlignMapping < ActiveRecord::Migration[6.1]
  def change
    create_table :align_mappings do |t|
      t.references :region
      t.references :align_mapping_set
      t.references :mapped_block, null: false, foreign_key: { to_table: :regions }
    end
  end
end
