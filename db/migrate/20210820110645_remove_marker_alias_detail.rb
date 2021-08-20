class RemoveMarkerAliasDetail < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :marker_names, :marker_alias_details
    drop_table :marker_alias_details
    add_column :marker_names, :description, :string
  end
end
