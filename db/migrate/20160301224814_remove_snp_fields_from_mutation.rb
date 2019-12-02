class RemoveSnpFieldsFromMutation < ActiveRecord::Migration[6.0]
  def change
    
    remove_foreign_key :mutations, :scaffolds
    remove_reference :mutations, :scaffold, index: true
    remove_foreign_key :mutations, :chromosomes
    remove_reference :mutations, :chromosome, index: true
    remove_column :mutations, :library, :string
    remove_column :mutations, :position, :integer
    remove_column :mutations, :ref_base, :string
    remove_column :mutations, :wt_base, :string
    remove_column :mutations, :alt_base, :string
  end
end
