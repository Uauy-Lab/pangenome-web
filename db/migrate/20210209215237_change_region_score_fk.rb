class ChangeRegionScoreFk < ActiveRecord::Migration[6.1]
  def change
  	remove_reference :region_scores , :kmer_analysis, foreign_key: true
  	add_reference :region_scores, :score_types, foreign_key: true
  end
end
