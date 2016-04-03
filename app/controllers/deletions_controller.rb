require 'set'

class DeletionsController < ApplicationController
	def query_for_lines
		return unless params[:lines_to_search] 
		return if params[:lines_to_search].size == 0
		lines = getLinesFromField( params[:lines_to_search])
		@dels, @primers  = findDeletionsForLines(lines)
		#puts @dels.inspect
	end

	def getLinesFromField(lines_to_search)
		arr = lines_to_search.split /[,\s]+/
		lines = Set.new
		arr.each do |e|  
			l = Line.find_by(name: e)
			lines << l if l
		end
		return lines
	end

	def findPrimersInContigAndLine(line, chromosome)
		
		query = "select chromosomes.name as chr, scaffold_maps.cm as cm,
scaffolds.name, snps.wt as wt, snps.alt as alt,
lines.name as line,  mutations.het_hom as mut_type,
primers.wt as primer_wt, primers.alt as priemrs_wt, primers.common as common,
primer_types.name as primer_type
from snps
JOIN primers on primers.snp_id = snps.id
JOIN primer_types on primer_types.id = primers.primer_type_id
JOIN scaffolds on snps.scaffold_id = scaffolds.id
JOIN scaffold_maps on scaffolds.id = scaffold_maps.scaffold_id
JOIN chromosomes on scaffolds.chromosome = chromosomes.id
JOIN mutations on mutations.snp_id = snps.id
JOIN libraries on mutations.library_id = libraries.id
JOIN `lines` on libraries.line_id = lines.id
WHERE 
lines.id = #{line.id.to_i} AND
chromosomes.id= #{chromosome.to_i}
ORDER BY chromosomes.name, cm"
		p = ActiveRecord::Base.connection.exec_query(query)
		p
	end

	def findDeletionsForLines(lines)
		dels = Hash.new
		primers = Hash.new
		exon_type = FeatureType.find_by(name: "exon")
		lines.each do |line|  
			ds =DeletedScaffold.includes(:scaffold).joins(:library,:scaffold).where(libraries:{line_id:line})
			next if ds.size == 0
			dels[line.name] = Array.new unless dels[line.name] 
			chromosomes = Set.new
			ds.each do |e|
				arr = Hash.new
				arr[:scaffold] = e.scaffold.name
				if e.scaffold.scaffold_maps.first
					sc_maps = e.scaffold.scaffold_maps.first 
					arr[:chromosome] = sc_maps.chromosome.name
					arr[:cm] = sc_maps.cm
					chromosomes << sc_maps.chromosome.id.to_i
				else
					chromosomes << e.scaffold.chromosome.to_i
				end
				arr[:cov_avg] = e.cov_avg
				feautres = Feature.joins(:region).where(feature_type:exon_type).where(regions:{scaffold_id:e.scaffold.id})
				regions = Array.new

				feautres.each do |e|  
					regions << e.region.to_s
				end
				regions.sort! {|left, right| left.size <=> right.size}
				arr[:regions] = regions

				dels[line.name] << arr
			end

			primers[line.name] = chromosomes.map { |c| findPrimersInContigAndLine(line, c) }
		end
		[dels, primers]
	end
end
