class CreateRegionScores < ActiveRecord::Migration[6.1]
  def change
    create_table :region_scores do |t|
      t.references :kmer_analysis, null: false, foreign_key: true
      t.references :region, null: false, foreign_key: true
      t.integer :vaule
    end
  end
end
