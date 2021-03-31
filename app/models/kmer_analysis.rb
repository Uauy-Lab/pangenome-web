class KmerAnalysis < ApplicationRecord
  belongs_to :line
  belongs_to :library
  belongs_to :assembly
  has_and_belongs_to_many :score_type
  has_many :region_score
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
			#puts ret.inspect
			ret
		#end
		#@scores.values
	end

	def self.scores_for(species, analysis, reference, sample, chr_name)
#Completed 200 OK in 234583ms (Views: 0.3ms | ActiveRecord: 233609.5ms | Allocations: 1874038)
		query = "  
SELECT  
species.name as species,
scaffolds.name as reference_chr,
regions.start,
regions.end,
assemblies.name as reference,
chromosomes.name as chr,
score_types.name as score,
score_types.id as score_id,
score_types.mantisa as mantisa,
region_scores.value as value
FROM region_scores
JOIN score_types   ON score_types.id = region_scores.score_types_id
JOIN kmer_analyses ON region_scores.kmer_analysis_id = kmer_analyses.id
JOIN regions       ON region_scores.region_id = regions.id
JOIN scaffolds     ON scaffolds.id = regions.scaffold_id
JOIN assemblies    ON assemblies.id = scaffolds.assembly_id
JOIN chromosomes   ON chromosomes.id = scaffolds.chromosome
JOIN species       ON chromosomes.species_id = species.id
JOIN libraries     ON libraries.id = kmer_analyses.library_id
WHERE 
species.name     = ? AND
kmer_analyses.name    = ? AND
assemblies.name  = ? AND
libraries.name     = ? AND
chromosomes.name = ?
;
"
	KmerAnalysis.find_by_sql([query, species, analysis, reference, sample, chr_name])
	end

	def self.find_analysis(analysis, assembly, library)

		#
#Completed 200 OK in 13ms (Views: 0.6ms | ActiveRecord: 3.0ms | Allocations: 7259)
		query="
SELECT 
kmer_analyses.id as kmer_analysis_id, 
kmer_analyses.name as name,
kmer_analyses.description as description, 
score_types.id as score_type_id, 
score_types.name as score_type_name, 
score_types.mantisa as score_type_mantisa, 
score_types.description as score_type_description,
libraries.name as library_name, 
libraries.description as library_description
FROM 
kmer_analyses 
JOIN kmer_analyses_score_types on kmer_analyses_score_types.kmer_analysis_id = kmer_analyses.id
JOIN score_types on kmer_analyses_score_types.score_type_id = score_types.id
JOIN assemblies on assemblies.id = kmer_analyses.assembly_id
JOIN libraries ON libraries.id = kmer_analyses.library_id
WHERE 
kmer_analyses.name    = ? AND
assemblies.name  = ? AND
libraries.name     = ? 
;
"
		KmerAnalysis.find_by_sql([query, analysis, assembly, library])
	end

	def self.scores(analys_id, chromosome)
		query = "
SELECT 
scaffolds.name               AS chromosome,
assemblies.name              AS reference,
regions.start                AS start,
regions.end                  AS end,
region_scores.value          AS value,
region_scores.score_types_id AS score_type_id,
assemblies.description              as asm
FROM
region_scores      
JOIN regions       ON region_scores.region_id = regions.id
JOIN scaffolds     ON scaffolds.id = regions.scaffold_id
JOIN chromosomes   ON chromosomes.id = scaffolds.chromosome
JOIN assemblies    ON scaffolds.assembly_id = assemblies.id
WHERE 
region_scores.kmer_analysis_id = ? AND
chromosomes.name = ? 
;"
		KmerAnalysis.find_by_sql([query, analys_id, chromosome])
	end
end
