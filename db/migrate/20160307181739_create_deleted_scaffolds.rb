class CreateDeletedScaffolds < ActiveRecord::Migration[6.0]
  def change
    create_table :deleted_scaffolds do |t|
      t.references :scaffold, index: true
      t.references :library, index: true
      t.float :cov_avg
      t.float :cov_sd

      t.timestamps null: false
    end
    add_foreign_key :deleted_scaffolds, :scaffolds
    add_foreign_key :deleted_scaffolds, :libraries
  end
end
