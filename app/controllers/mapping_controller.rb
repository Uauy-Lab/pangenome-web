class MappingController < ApplicationController
  before_action :mapping_params
  def coordinate_mapping
    puts(@scaffold)
    
    @blocks_csv = CoordinateMappingHelper.coordinate_mapping_in_regin(@scaffold, @start, @end, @align_mapping_set)
    
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
