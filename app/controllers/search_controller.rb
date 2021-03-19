
class SearchController < ApplicationController



	def list
		session[:lines] = params[:lines] if params[:lines]
		session[:scaffolds] = params[:scaffolds] if params[:scaffolds]
		session[:genes] = params[:genes] if params[:genes]
		session[:population] = params[:population] if params[:population]
		session[:region]= nil if request.format != 'json'
		session[:region] = params[:region] if params[:region]

		@search = params[:search]
		@population = params[:population] if params[:population]
		records = nil
		#puts "Regions: #{session[:region]}"
		case params[:search]

		when "scaffolds"
			records = find_snps_by_scaffolds(session[:scaffolds], category: params[:category], population: session[:population]) if request.format == 'json'  and not session[:region]
			records = find_snps_by_regions(prepare_regions, category: params[:category], population: session[:population]) if request.format == 'json' and  session[:region]
		when "lines"
			records = find_snps_by_line(session[:lines], category: params[:category], population: session[:population]) if request.format == 'json'
			flash[:info] = "Searching for all the mutations in a line can take up to 10 minutes"  unless session[:alert_line_displayed]
			session[:alert_line_displayed] = true
		when "genes"
			records = find_snps_by_genes(session[:genes], category: params[:category], population: session[:population]) if request.format == 'json'
		end
		respond_to do |format|
			format.html
			format.json {
				render json: records
			}
		end
	end

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

	
	def autocomplete
		search = "%#{params[:term]}%"
		genes = Feature.where("parent_id is  NULL AND name LIKE ? ", search)
		.limit(7)

		arr = genes.map(&:name)

		scaffolds = Scaffold.where("name LIKE ?", search ).limit(7)
		arr.push(*scaffolds.map(&:name))

		lines = Line.where("mutant = 'Y' and name LIKE ?  ", search)
		.limit(7)

		arr.push(*lines.map(&:name))
		respond_to do |format|
			format.html
			format.json {
				render json: arr
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
		terms =  ActionController::Base.helpers.strip_tags terms

		chr = Chromosome.find(params[:chromosome].to_i)
		sp = Species.find(params[:species].to_i)
		path = "/#{sp.name}/haplotype/#{chr.name}"
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
