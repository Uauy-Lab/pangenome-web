class MappingController < ApplicationController

	before_action :mapping_params

	def coordinate_mapping
		puts(@scaffold)
		mappings = AlignMapping.in_region(@scaffold, @start, @end, @align_mapping_set)
		@blocks_csv = []
		@blocks_csv << ["assembly", "reference", "chromosome", "start", "end", "block_no", "region_id", "mapping_region_id"].join("\t")
		blocks = []
		mapped_regions = Set.new

		mappings.to_a.sort.each do |am|
			mapped_regions << am.mapped_block
		end

		mapped_regions.each do |mr|
			mappings = AlignMapping.where(["align_mapping_set_id = :mapping_set AND mapped_block_id = :mapped_block" , 
				mapping_set: @align_mapping_set.id, 
				mapped_block: mr.id])
			@blocks_csv << mr.to_s
			mappings.each do |am|
				region = am.region
				rs = Scaffold.cached_from_id(region.scaffold.id)
				mrs = Scaffold.cached_from_id(mr.scaffold.id)
				b = [mrs.assembly.name ,rs.assembly.name, region.name, region.start, region.end , mr.simple_s, region.id, mr.id ]
				@blocks_csv << b.join("\t")
			end
		end


		respond_to do |format|
      		format.csv do
      			 send_data @blocks_csv.join("\n"), filename: "#{@scaffold.name}.#{@start}.#{@end}.csv" 
      		end
    	end

	end

	private

	def mapping_params
		params.require("chr")
		params.require( "start")
		params.require("end")
		params.require("align_set_id")
		params.require("species")
		@align_mapping_set = AlignMappingSet.find(params[:align_set_id])
		@scaffold = Scaffold.find_by( name: params[:chr])
		@start = params[:start].to_i
		@end   = params[:end].to_i
	end
end