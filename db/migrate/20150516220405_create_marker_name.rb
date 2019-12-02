class CreateMarkerName < ActiveRecord::Migration[6.0]
  def change
    create_table :marker_names do |t|
      t.string :alias
      t.references :marker, index: true
    end
    add_foreign_key :marker_names, :markers
  end
end
