class AddChromosomeToScaffold < ActiveRecord::Migration[6.0]
  def change
    add_column :scaffolds, :chromosome, :string
  end
end
