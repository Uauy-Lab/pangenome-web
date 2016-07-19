class ChangeDataTypeForScaffoldChromosome < ActiveRecord::Migration
  def change
  	change_column :scaffolds, :chromosome,  :int
  end
end
