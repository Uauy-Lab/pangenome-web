class AddChromosomeToScaffold < ActiveRecord::Migration
  def change
    add_column :scaffolds, :chromosome, :string
  end
end
