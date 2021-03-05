class CreateJoinTableKmerAnalysisScoreTypes < ActiveRecord::Migration[6.1]
  def change
    create_join_table :kmer_analyses, :score_types do |t|
       #t.index [:kmer_analysis_id, :score_type_id]
       #t.index [:score_type_id, :kmer_analysis_id]
    end
  end
end
