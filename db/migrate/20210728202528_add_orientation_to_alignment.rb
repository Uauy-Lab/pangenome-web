class AddOrientationToAlignment < ActiveRecord::Migration[6.1]
  def change
    add_column :alignments, :orientation, :string ,  limit: 1
    remove_reference :alignments, :feature_type, index: true, foreign_key: true
  end
end
