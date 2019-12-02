class AddLibraryToMutation < ActiveRecord::Migration[6.0]
  def change
    add_reference :mutations, :library, index: true
    add_foreign_key :mutations, :libraries

    #remove_foreign_key :mutations, :mutant_line
    remove_column :mutations, :mutant_line_id, :references
  end
end
