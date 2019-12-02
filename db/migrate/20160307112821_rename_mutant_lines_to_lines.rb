class RenameMutantLinesToLines < ActiveRecord::Migration[6.0]
  def change
  	rename_table :mutant_lines, :lines
  end
end
