require 'bio-pangenome'

class KmerScoreController < ApplicationController
	def get_kmer_scores
		chr_name  = params[:chr_name] 
		species   = params[:species]
		analysis  = params[:analysis]
		reference = Assembly.find_by(description: params[:reference] )
		reference = reference.name
		sample    = params[:sample]
		puts params.inspect
		puts reference


		expires = 2.weeks

		@ret = Rails.cache.fetch("scores/#{species}/#{analysis}/#{reference}/#{sample}/#{chr_name}", expires: expires) do |variable|
			ret = {}
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
					ret[:score_keys]  = []
	  			end
	  			first = false
	  			ret[:scores][e.score_type_id] = {
	  				:id      => e.score_type_id, 
	  				:name    => e.score_type_name,
	  				:mantisa => e.score_type_mantisa,
	  				:desc    => e.score_type_description,
	  				:values  => Array.new
	  			}
	  			ret[:score_keys] << e.score_type_id

			end
			
			ret[:reference] = reference 
			scores = KmerAnalysis.scores(ret[:id], chr_name)
			scores.each do |s|
				ret[:scores][s.score_type_id][:values] << {
					:chromosome => s.chromosome,
					:reference  => s.reference,
					:start      => s.start,
					:end        => s.end, 
					:value      => s.value, 
					:assembly   => s.asm
				}
			end
			ret
		end 
		
		respond_to do |format|
			format.csv do 
				send_data @ret.join("\n")
			end

			format.json do 
				send_data @ret.to_json
			end
		end
	end

	def show
		@chr = params[:chr_name]
		@species = params[:species]
		session_chromosome(chr: @chr)
		species = Species.find_by_name(@species)
		@hap_sets = HaplotypeSetHelper.find_hap_sets(species: @species, chr: @chr)
    	session_chromosome(chr: @chr)

	    @assemblies =  species.assemblies.map {|a| "'#{a.description}'"}.join(",")

	#    puts @assemblies

	#http://localhost:3000/haplotype_set/Wheat/haps/6A.csv
	    @csv_paths = Hash.new
	    @hap_sets.each do |h_s| 
	      @csv_paths[h_s.name] =  "/#{@species}/haplotype/#{@chr}/#{h_s.name}.csv" 
	    end
	    @hap_set  = @hap_sets.last
	 
	  	respond_to do |format|
	      format.html
	    end

	end
end
