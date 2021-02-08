class CreateKmerAnalyses < ActiveRecord::Migration[6.1]
  def change
    create_table :kmer_analyses do |t|
      t.references :line, null: false, foreign_key: true
      t.references :assembly, null: false, foreign_key: true
      t.timestamps
    end
  end
end
