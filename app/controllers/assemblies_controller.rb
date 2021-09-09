require 'bio-pangenome'

class AssembliesController < ApplicationController
  include AssembliesHelper

  before_action :assemblies_params

  def coordinate_mappig
    mapping_id ="#{@species.name}_#{@chromosome.name}_#{@window_size}"
    blocks = Rails.cache.fetch(mapping_id) do
      getRegionWindows(window_size: @window_size)
    end

    @blocks_csv = []
    @blocks_csv << ["assembly", "reference", "chromosome", "start", "end", "block_no", "chr_length"].join(",")
    blocks.each do |b|
      @blocks_csv << b.to_csv
    end
    respond_to do |format|
      format.csv do
        send_data @blocks_csv.join("\n"), filename: "#{mapping_id}.csv" 
      end
    end
  end

  private

  def assemblies_params
    params.require("chr_name")
    params.require("species")
    params.permit("window_size", "species", "chr_name", "format")
    @species = Species.find_by(name: params[:species])
    @chromosome = Chromosome.find_by(name: params[:chr_name], species: @species)
    @window_size = params[:window_size].to_i
  end
end