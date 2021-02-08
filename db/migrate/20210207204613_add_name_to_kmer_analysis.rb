class AddNameToKmerAnalysis < ActiveRecord::Migration[6.1]
  def change
  	add_column :kmer_analyses, :name, :string
  	add_column :kmer_analyses, :description, :text
  	add_reference :kmer_analyses, :library
  end
end
