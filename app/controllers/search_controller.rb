
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

	def prepare_regions
		regions = Array.new
		scaffold = session[:scaffolds][0]
		#puts "Preparing regions...#{scaffold} : #{session[:region]}"

		session[:region].each do |r|
			reg = Bio::DB::Fasta::Region.parse_region("#{scaffold}:#{r}")
			regions<<reg
		end
		regions
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
		search = terms.split(/[,\s]+/).map { |e| e.strip }
		myfile = params[:query_file]

		population = params[:population] if params[:population]
		population = nil if population == "All"

		if myfile
			search_terms = File.read(myfile.path)
			search_terms =  ActionController::Base.helpers.strip_tags search_terms
			arr = []
			begin
				arr = search_terms.split(/[,\s]+/).map { |e| e.strip }
			rescue Exception
				arr = ["Invalid file"]
			end

			search.push(*arr)
		end

		lines, to_search = find_lines(search, population)
		genes, to_search = find_genes(to_search)
		scaffolds, to_search = find_scaffolds(to_search)
		session[:lines] = nil
		session[:scaffolds] = nil
		session[:genes] = nil
		session[:population] = population
		if params[:terms].include? "IWGSC_3BSEQ_3B_traes3bPseudomoleculeV1"
			flash[:error] = "At the moment, the search for all the SNPs in:
			'IWGSC_3BSEQ_3B_traes3bPseudomoleculeV1'.
			Try searching by your genes of interest"
			redirect_to :back
		elsif search.size == 0
			flash[:error] = "Missing search terms.
			Please check that:
			 <li><ul>The form has terms or a file is slected</ul><
			 <ul>The lines you tiped correspond to the selected population</ul></li>.
			 <br/>"
			redirect_to :back
		elsif lines.size == search.size
			session[:lines] = lines.join ","
			lines.empty if lines.size > 10
			redirect_to  action: "list", lines: lines, search: :lines, population: population
		elsif scaffolds.size == search.size
			session[:scaffolds] = scaffolds.join ","
			scaffolds.empty if scaffolds.size > 10
			redirect_to  action: "list", scaffolds: scaffolds, search: :scaffolds, population: population
		elsif genes.size == search.size
			session[:genes] = genes.join ","
			genes.empty if genes.size > 10
			redirect_to  action: "list", genes: genes, search: :genes, population: population
		else
			flash[:error] = "Make sure that all your search fields are from the same category and the lines correspond to the selected population.  <br/>"
			flash[:error] << "Lines: #{lines.join(", ")} <br/>"
			flash[:error] << "Scaffolds: #{scaffolds.join(", ")} <br/>"
			flash[:error] << "Genes: #{genes.join(", ")} <br/>"
			flash[:error] << "Not found: #{to_search.join(", ")} <br/>"
			redirect_to :back
		end
	end


	private
	def get_query_string_snp_details_short
		sql=%{ SELECT DISTINCT
	snps.id as recid,
	snps.scaffold_id as scaffold,
	snps.scaffold_id as chr,
	mutations.library_id as library,
	confidence as category,
	snps.position as position,
    #scaffold_mappings.other_coordinate as chr_position,
	snps.ref as ref,
	snps.wt as wt,
	snps.alt as alt,
	mutations.het_hom as het_hom,
	mutations.wt_cov as wt_cov,
	mutations.mut_cov as mut_cov,
	features.name as gene,
	effects.effect_type_id as effect_type	,
	effects.cdna_position as cdna_position,
	effects.cds_position as cds_position,
	effects.amino_acids as amino_acids,
	effects.codons as codons,
	effects.sift_score as sift,
	primers.primer_type_id  as primer_type,
	primers.orientation as primer_orientation,
	primers.wt as wt_primer,
	primers.alt as alt_primer,
	primers.common as common_primer
FROM snps
LEFT JOIN primers on primers.snp_id = snps.id
LEFT JOIN mutations on mutations.SNP_id = snps.id
LEFT JOIN effects on effects.snp_id = snps.id
LEFT JOIN features on effects.feature_id = features.id
#LEFT JOIN scaffold_mappings ON scaffold_mappings.scaffold_id = snps.scaffold_id AND scaffold_mappings.coordinate = snps.position
}
	sql
	end

	def get_query_string_snp_details
		sql=%{
 SELECT DISTINCT
	snps.id as recid,
	scaffolds.name as scaffold,
	chromosomes.name as chr,
	`lines`.name as line,
	confidence as category,
	snps.position as position,
	scaffolds.id as chr_position,
#    scaffold_mappings.other_coordinate as chr_position,
	snps.ref as ref,
	snps.wt as wt,
	snps.alt as alt,
	mutations.het_hom as het_hom,
	mutations.wt_cov as wt_cov,
	mutations.mut_cov as mut_cov,
	features.name as gene,
	effect_types.name as consequence	,
	effects.cdna_position as cdna_position,
	effects.cds_position as cds_position,
	effects.amino_acids as amino_acids,
	effects.codons as codons,
	effects.sift_score as sift,
	primer_types.name  as primer_type,
	primers.orientation as primer_orientation,
	primers.wt as wt_primer,
	primers.alt as alt_primer,
	primers.common as common_primer
FROM snps
JOIN scaffolds ON scaffolds.id = snps.scaffold_id
LEFT JOIN primers on primers.snp_id = snps.id
LEFT JOIN primer_types on primer_types.id = primers.primer_type_id
LEFT JOIN mutations on mutations.SNP_id = snps.id
LEFT JOIN libraries on mutations.library_id = libraries.id
LEFT JOIN `lines` on libraries.line_id  = `lines`.id
LEFT JOIN effects on effects.snp_id = snps.id
LEFT JOIN effect_types on effect_types.id = effects.effect_type_id
LEFT JOIN features on effects.feature_id = features.id
LEFT JOIN chromosomes on scaffolds.chromosome = chromosomes.id
#LEFT JOIN scaffold_mappings ON scaffold_mappings.scaffold_id = snps.scaffold_id AND scaffold_mappings.coordinate = snps.position
		}
		return sql
	end

	def addExtrasnAndOrderToSQL(population: nil, category:nil)
		extra = ''
		if population and population.size > 0
			pop = Line.find_by(name: population)
			extra << " AND `lines`.wildtype_id = #{pop.id}"
		end

		extra << " AND confidence = '#{category}' " if category and category.size > 0
		#extra << " ORDER BY scaffolds.name, snps.position"
		extra
	end

	def find_snps_by_scaffolds(arr, population: nil, category: nil)
		Rails.cache.fetch("scaffolds/#{population}/#{category}/#{arr.to_s}") do
			sql = get_query_string_snp_details
			ids = arr.map do |e|
				#This is a temporary patch for 3B!
				next if e == 'IWGSC_3BSEQ_3B_traes3bPseudomoleculeV1'
				Scaffold.find_by(name: e)
			end
			ids.compact!
			raise "No scaffolds found for #{arr.join(",")}" if ids.size == 0
			ids = ids.map { |e| e.id }
			sql << "WHERE scaffolds.id IN (#{ids.join(",")})"
			sql << addExtrasnAndOrderToSQL(population:population, category:category)
			records_array = ActiveRecord::Base.connection.execute(sql)
			result_set_to_json(records_array)
		end
	end

	def find_snps_by_regions(arr, population: nil, category: nil)
		Rails.cache.fetch("regions/#{population}/#{category}/#{arr.to_s}") do
			puts "running cache"
			sql = get_query_string_snp_details
			ids = arr.map do |e|
				Scaffold.find_by(name: e.entry)
			end
			ids = ids.map { |e| e.id }
			ids.compact!

			raise "No scaffolds found for #{arr.join(",")}" if ids.size == 0
			#raise "Finding by regions only supported for regions of the same sacffold" unless ids.size == 1
			regions = arr.map do |e|
				"snps.position BETWEEN #{e.start} AND #{e.end}"
			end
			regions_str = regions.join(" OR ")

			sql << "WHERE scaffolds.id IN (#{ids.join(",")}) AND (#{regions_str}) "
			sql << addExtrasnAndOrderToSQL(population:population, category:category)
			records_array = ActiveRecord::Base.connection.execute(sql)
			result_set_to_json(records_array)
		end
	end

	def find_snps_by_line(arr, population: nil, category: nil)
		Rails.cache.fetch("lines/#{population}/#{category}/#{arr.to_s}") do
			sql = get_query_string_snp_details
			ids = arr.map { |e|  Line.find_by(name: e) }
			ids.compact!
			raise "No lines found for #{arr.join(",")}" if ids.size == 0

			ids = ids.map { |e| Library.find_by(line_id: e.id).id }
			sql << "WHERE mutations.library_id IN (#{ids.join(",")})"

			sql << addExtrasnAndOrderToSQL(population:population, category:category)
			#puts sql
			records_array = ActiveRecord::Base.connection.execute(sql)
			result_set_to_json(records_array)
		end
	end

	def find_snps_by_genes(arr, population: nil, category: nil)
		Rails.cache.fetch("genes/#{population}/#{category}/#{arr.to_s}") do
			sql = get_query_string_snp_details
			ids = arr.map { |e|  Feature.find_by(name: e) }
			ids.compact!
			raise "No lines features for #{arr.join(",")}" if ids.size == 0
			ids = ids.map { |e| e.id }
			sql << "WHERE `features`.id IN (#{ids.join(",")}) OR features.parent_id IN (#{ids.join((","))})"
			sql << addExtrasnAndOrderToSQL(population:population, category:category)
			records_array = ActiveRecord::Base.connection.execute(sql)
			result_set_to_json(records_array)
		end
	end

	#Returns the scaffold name from the scaffold ID.
	#nternally, it stores the scaffolds in a cache.
	def primer_type_name
		Rails.cache.fetch("primer_type_name") do
    		h = Hash.new
      		PrimerType.all.each { |e| h[e.id] = e.name }
      		h
    	end
	end

	def chromosome_mappings_for_scaffold(scaffold)
		Rails.cache.fetch("chromosome_map/#{scaffold}") do
			h = Hash.new
			ScaffoldMapping.where(scaffold_id: scaffold).find_each { |e| h[e.coordinate] = e.other_coordinate }
			h
		end
	end

	def other_coordinate(scaffold: nil, coordinate: nil)
		r = chromosome_mappings_for_scaffold(scaffold)[coordinate]
		r = "" if r.nil?
		r
	end

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


	def find_lines(arr, population)
		lines = Array.new
		to_search = Array.new
		arr.each do |e|
			e.chomp!
			l = Line.find_by(name: e)
			l = nil if l and  population and l.wildtype.name != population
			if l
				lines << l.name
			else
				to_search << e
			end
		end
		return [lines, to_search]
	end

	def find_scaffolds(arr)
		scaffolds = Array.new
		to_search = Array.new
		arr.each do |e|
			e.chomp!
			toks = e.split("_")
			e = "IWGSC_CSS_#{toks[0]}_scaff_#{toks[1]}" if toks.size == 2
			l = Scaffold.find_by(name: e)
			if l
				scaffolds << l.name
			else
				to_search << e
			end
		end
		return [scaffolds, to_search]
	end

	def find_genes(arr)
		scaffolds = Array.new
		to_search = Array.new
		arr.each do |e|
			e.chomp!
			l = Feature.find_by(name: e)

			if l
				scaffolds << l.name
			else
				to_search << e
			end

		end
		return [scaffolds, to_search]
	end


	def search_params
		params.require(:search).permit(:region,:population, :terms, :query_file, :sequence, :category)
	end
end
