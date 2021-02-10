class KmerAnalysis < ApplicationRecord
  belongs_to :line
  belongs_to :library
  belongs_to :assembly
  has_and_belongs_to_many :score_type

  def init_scores
  	score_type  << ScoreType.find_or_create_by(name: "total_kmers",    description: "Total Kmers", mantisa: 0)
	score_type  << ScoreType.find_or_create_by(name: "observed_kmers", description: "Observed Kmers", mantisa: 0)
	score_type  << ScoreType.find_or_create_by(name: "variations",     description: "Variations", mantisa: 0)
	score_type  << ScoreType.find_or_create_by(name: "kmer_distance",  description: "Kmer distance", mantisa: 0)
	score_type  << ScoreType.find_or_create_by(name: "perc_kmers",     description: "Kmers Percentage", mantisa: -6)
  end 

  def score(name)
		@scores ||= self.scores
		return @scores[name]
	end

	def scores
		#@scores = Rails.cache.fetch("kmer_analysis/scores") do
			ret = Hash.new
			self.score_type.each do |score|
				ret[score.name] = score
			end
			puts ret.inspect
			ret
		#end
		#@scores.values
	end



end
