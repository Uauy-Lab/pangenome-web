class RenameMutantLinesToLines < ActiveRecord::Migration
  def change
  	rename_table :mutant_lines, :lines
  end
end
