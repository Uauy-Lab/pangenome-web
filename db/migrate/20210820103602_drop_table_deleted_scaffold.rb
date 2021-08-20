class DropTableDeletedScaffold < ActiveRecord::Migration[6.1]
  def change
    drop_table :deleted_scaffolds
  end
end
