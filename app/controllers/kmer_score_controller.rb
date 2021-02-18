require 'bio-pangenome'

class KmerScoreController < ApplicationController
	def get_kmer_scores
		chr_name  = params[:chr_name] 
		species   = params[:species]
		analysis  = params[:analysis]
		reference = params[:reference]
		sample    = params[:sample]
		puts params.inspect
		expires = 2.weeks

		ret = {}

		#scores = KmerAnalysis.scores_for(species, analysis, reference, sample, chr_name)

		#scores.each do |e|  
		#	ret <<  [ e.species, e.reference_chr, e.start, e.end, e.reference, e.chr, e.score, e.score_id, e.mantisa, e.value].join("\t")
		#end
		analysis = KmerAnalysis.find_analysis(analysis, reference, sample)

		first = true
		analysis.each do |e|
			if first 
				ret[:id ]         = e.kmer_analysis_id
				ret[:name]        = e.name
				ret[:desc]        = e.description
				ret[:sample]      = e.library_name
				ret[:sample_desc] = e.library_description
				ret[:scores]      = {}
  			end
  			first = false
  			ret[:scores][e.score_type_id] = {
  				:id      => e.score_type_id, 
  				:name    => e.score_type_name,
  				:mantisa => e.score_type_mantisa,
  				:desc    => e.score_type_description,
  				:values  => Array.new
  			}

		end
		ret[:reference] = reference 

		scores = KmerAnalysis.scores(ret[:id], chr_name)
		scores.each do |s|
			ret[:scores][s.name][:values] << {
				:chromosome => s.chromosome,
				:reference  => s.reference,
				:start      => s.start,
				:end        => s.end, 
				:value      => s.value, 
				:assembly   => s.asm
			}
		end


		respond_to do |format|
			format.csv do 
				send_data ret.join("\n")
			end

			format.json do 
				send_data ret.to_json
			end
		end
	end
end
