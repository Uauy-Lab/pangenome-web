class RemoveTimestampsFromAlignment < ActiveRecord::Migration[6.1]
  def change
    remove_column :alignments, :created_at, :string
    remove_column :alignments, :updated_at, :string
    #remove_reference :alignments, :feature_type, index: true, foreign_key: true
  end
end
