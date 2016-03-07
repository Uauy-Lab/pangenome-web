class RenameLibraryLineColumn < ActiveRecord::Migration
  def change
  	remove_foreign_key :libraries, :mutant_lines
  	rename_column :libraries, :mutant_line_id, :line_id
  	add_foreign_key :libraries, :lines
  end
end
