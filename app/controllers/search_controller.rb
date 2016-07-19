class SearchController < ApplicationController
	
	def list
		session[:lines] = params[:lines] if params[:lines]
		session[:scaffolds] = params[:scaffolds] if params[:scaffolds]
		session[:genes] = params[:genes] if params[:genes]
		session[:population] = params[:population] if params[:population]
		@search = params[:search]
		@population = params[:population] if params[:population]
		records = nil
		case params[:search]
		when "scaffolds"
			records = find_snps_by_scaffolds(session[:scaffolds],population: session[:population]) if request.format == 'json'
		when "lines" 
			records = find_snps_by_line(session[:lines], population: session[:population]) if request.format == 'json'
		when "genes"
			records = find_snps_by_genes(session[:genes], population: session[:population]) if request.format == 'json'
		end
		respond_to do |format|
			format.html
			format.json {
				render json: records
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

	def redirect

		terms = params[:terms]
		search = params[:terms].split(/[,\s]+/).map { |e| e.strip }
		myfile = params[:query_file]
		population = params[:population] if params[:population]
		population = nil if population == "All"
		if myfile
			search_terms = File.read(myfile.path)
			arr = search_terms.split(/[,\s]+/).map { |e| e.strip }
			search.push(*arr)   
		end

		lines, to_search = find_lines(search, population)
		scaffolds, to_search = find_scaffolds(to_search)
		genes, to_search = find_genes(to_search)
		session[:lines] = nil
		session[:scaffolds] = nil
		session[:genes] = nil
		session[:population] = population

		if search.size == 0
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

	def get_query_string_snp_details 
		sql=%{
SELECT DISTINCT
	snps.id as recid,
	scaffolds.name as scaffold, 
	chromosomes.name as chr, 
	`lines`.name as line,
	snps.position as position,
	scaffold_mappings.other_coordinate as chr_position, 
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
JOIN scaffold_mappings ON scaffold_mappings.scaffold_id = snps.scaffold_id AND scaffold_mappings.coordinate = snps.position
LEFT JOIN chromosomes on scaffolds.chromosome = chromosomes.id
LEFT JOIN mutations on mutations.SNP_id = snps.id
LEFT JOIN libraries on mutations.library_id = libraries.id
LEFT JOIN `lines` on libraries.line_id  = `lines`.id
LEFT JOIN effects on effects.snp_id = snps.id
LEFT JOIN effect_types on effect_types.id = effects.effect_type_id
LEFT JOIN features on effects.feature_id = features.id
LEFT JOIN primers on primers.snp_id = snps.id
LEFT JOIN primer_types on primer_types.id = primers.primer_type_id
		}
		return sql
	end
	
	def addPopulationAndOrderToSQL(population: nil)
		extra = ''
		if population and population.size > 0
			pop = Line.find_by(name: population)
			extra << " AND `lines`.wildtype_id = #{pop.id}"
		end
		extra << " ORDER BY scaffolds.name, snps.position"
		extra
	end

	def find_snps_by_scaffolds(arr, population: nil)
		sql = get_query_string_snp_details
		ids = arr.map { |e|  Scaffold.find_by(name: e) }
		ids.compact!
		raise "No scaffolds found for #{arr.join(",")}" if ids.size == 0
		ids = ids.map { |e| e.id }
		sql << "WHERE scaffolds.id IN (#{ids.join(",")})"
		sql << addPopulationAndOrderToSQL(population:population)
		records_array = ActiveRecord::Base.connection.execute(sql)
		result_set_to_json(records_array)
	end

	def find_snps_by_line(arr, population: nil)
		sql = get_query_string_snp_details
		ids = arr.map { |e|  Line.find_by(name: e) }
		ids.compact!
		raise "No lines found for #{arr.join(",")}" if ids.size == 0
		ids = ids.map { |e| e.id }
		sql << "WHERE `lines`.id IN (#{ids.join(",")})"
		sql << addPopulationAndOrderToSQL(population:population)
		records_array = ActiveRecord::Base.connection.execute(sql)
		result_set_to_json(records_array)
	end

	def find_snps_by_genes(arr, population: nil)
		sql = get_query_string_snp_details
		ids = arr.map { |e|  Feature.find_by(name: e) }
		ids.compact!
		raise "No lines features for #{arr.join(",")}" if ids.size == 0
		ids = ids.map { |e| e.id }
		sql << "WHERE `features`.id IN (#{ids.join(",")}) OR features.parent_id IN (#{ids.join((","))})"
		sql << addPopulationAndOrderToSQL(population:population)
		records_array = ActiveRecord::Base.connection.execute(sql)
		result_set_to_json(records_array)
	end


	def result_set_to_json(records_array)
		fields = records_array.fields
		records=Array.new
		records_array.each do |record| 
			record_h = Hash.new
			record.each_with_index { |e, i| record_h[fields[i]] = e }
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
		params.require(:search).permit(:population, :terms, :query_file)
	end
end
