class MappingController < ApplicationController
  before_action :mapping_params
  def coordinate_mapping
    puts(@scaffold)
    mappings = AlignMapping.in_region(@scaffold, @start, @end, @align_mapping_set)
    @blocks_csv = []
    @blocks_csv << ["assembly", "reference", "chromosome", "start", "end", "block_no", "region_id", "mapping_region_id"].join(",")
    mapped_regions = Set.new
    mappings.each do |am|
      mapped_regions << am.mapped_block_id
    end
    mappings  = AlignMapping.where(align_mapping_set: @align_mapping_set ).where(mapped_block: mapped_regions)
    mr      = Region.new
    mr.id    = 0
    mrs      = ""
    mr_simple = ""
    mr_asm   = ""
    mappings.each do |am|
      region = am.region
      rs = Scaffold.cached_from_id(region.scaffold_id)
      if mr.id != am.mapped_block_id
        mr = am.mapped_block
        mrs = Scaffold.cached_from_id(mr.scaffold_id)
        mr_simple = "#{mrs.name}:#{mr.start}-#{mr.end}"
        mr_asm = mrs.assembly.name
      end
      b = [ mr_asm,rs.assembly.name, region.name, region.start, region.end , mr_simple, region.id, mr.id ]
      @blocks_csv << b.join(",")
    end
    respond_to do |format|
      format.csv do
        send_data @blocks_csv.join("\n"), filename: "#{@scaffold.name}.#{@start}.#{@end}.csv"
      end
    end
  end

  def zoomed
    respond_to do |format|
      format.html
    end
  end

  private
  def mapping_params
    params.require("chr")
    params.require("start")
    params.require("end")
    params.require("align_set_id")
    params.require("species")
    @align_mapping_set = AlignMappingSet.find(params[:align_set_id])
    @scaffold = Scaffold.find_by( name: params[:chr])
    @start = params[:start].to_i
    @end   = params[:end].to_i
    @species_inside = params[:species]
    puts "_____"
    puts params
  end
end
