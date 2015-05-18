class CreateMarkerAliasDetails < ActiveRecord::Migration
  def change
    create_table :marker_alias_details do |t|
      t.string :alias_detail
      t.string :description
      t.timestamps null: false
    end
  end
end
