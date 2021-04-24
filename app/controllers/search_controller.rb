
class SearchController < ApplicationController


	def feature
		records = Feature.autocomplete(
			params[:query], 
			type: params[:type], 
			species: params[:species],
			chromosome: params[:chromosome],
			limit: 30
			)
		ret = records.map { |e| e.name }
		respond_to do |format|
			format.json {
				render json:ret
			}
		end
	end

	def any
		params = search_params
		query = params[:query]
		feature = Feature.find_by(name: query)
		if(feature)
			chromosome = feature.chromosome
			sp = chromosome.species
			path  = "/#{sp.name}/haplotype/#{chromosome.name}?gene=#{query}"
			redirect_to path
		else
			flash[:error] = "#{query} not found"
			url = request.referer.to_s
			redirect_to url
		end
	end


	def coordinates
		records = Feature.autocomplete(
			params[:query], 
			type: params[:type], 
			species: params[:species],
			chromosome: params[:chromosome],
			limit: 1,
			exact: true
			)
		ret = {
			feature:    params[:query],
			type:       params[:type],
			chromosome: params[:chromosome],
			found:      false,
			mappings: []	
		}

		feature = records.first
		if feature
			records = FeatureHelper.find_mapped_feature(feature)
			species = Species.find_by(name: params[:species])
			recs = Hash.new
			records.each do |r| 
				recs[r.asm.name]  =  r
			end
			cannonical_assembly = species.cannonical_assembly
			features = species.assemblies.map do |asm|
				f = recs[asm.name]
				f = recs[cannonical_assembly.name] unless asm.is_pseudomolecule
				{
					reference:  f.asm.name, 
					assembly:    asm.description,
					assemby_id: asm.name,
					chromosome: f.chr, 
					start: f.start, 
					end: f.to, 
					feature: f.name,
					search_feature: params[:query]
				}
			end
			ret[:found]    = true
			ret[:mappings] = features
		end
		respond_to do |format|
			format.json {
				render json:ret
			}
		end
	end



	def sequence
		region = FASTA_DB.index.region_for_entry(params[:sequence])

		sequence = "Sequence not found"
		sequence = "The contig/chromosome is too big to be fetched. Please download the full reference." if region and region.length >= 500000
		sequence = FASTA_DB.fetch_sequence(region.get_full_region) if region and region.length < 500000
		split_seq = sequence.scan(/.{1,60}/m)
		f = ">#{params[:sequence]}\n#{split_seq.join("\n")}"
		respond_to do |format|
			format.html{
				render plain: f
			}
		end
	end

	def redirect
		puts "?----------------------?"
		puts params.inspect
		terms = params[:terms]
		terms = ActionController::Base.helpers.strip_tags terms
		chr   = Chromosome.find(params[:chromosome].to_i)
		sp    = Species.find(params[:species].to_i)
		session_hap_set(hap_set: params[:hap_set]) 
		path  = "/#{sp.name}/haplotype/#{chr.name}"
		redirect_to path
	end

	

	private

	def result_set_to_json(records_array)
		fields = records_array.fields
		records=Array.new
		records_array.each do |record|
			record_h = Hash.new
			record.each_with_index do |e, i|
				record_h[fields[i]] = e == nil ? "": e
			end
			record_h["chr_position"] = other_coordinate(scaffold: record_h["chr_position"], coordinate: record_h["position"] )
			records << record_h
		end
		{"total" => records.size, "records" =>records}
	end

	def search_params
		params.permit(:region,:population, :commit, :terms, :query_file, :sequence, :category, :query)
	end
end
