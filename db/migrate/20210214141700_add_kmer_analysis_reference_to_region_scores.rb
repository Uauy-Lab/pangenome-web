class AddKmerAnalysisReferenceToRegionScores < ActiveRecord::Migration[6.1]
  def change
  	add_reference :region_scores, :kmer_analysis
  end
end
