
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

	def coordinates
		records = Feature.autocomplete(
			params[:query], 
			type: params[:type], 
			species: params[:species],
			chromosome: params[:chromosome],
			limit: 1,
			exact: true
			)
		feature = records.first
		records = FeatureHelper.find_mapped_feature(feature)
		ret = {
			feature:    params[:query],
			type:       params[:type],
			chromosome: params[:chromosome],
			mappings:   records.map do |f|
				{
					assembly: f.asm.name, 
					chromosome: f.chr, 
					start: f.start, 
					end: f.to, 
					feature: f.name
				}
			end
		}
		
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
		terms = params[:terms]
		terms = ActionController::Base.helpers.strip_tags terms
		chr   = Chromosome.find(params[:chromosome].to_i)
		sp    = Species.find(params[:species].to_i)
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
		params.require(:search).permit(:region,:population, :terms, :query_file, :sequence, :category)
	end
end
