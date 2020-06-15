require 'bio-pangenome'

class AssembliesController < ApplicationController
	 include AssembliesHelper

	before_action :assemblies_params

	def coordinate_mappig

		puts @species

		blocks = getRegionWindows()
		respond_to do |format|
			format.json do
				render :json => blocks
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
    end

end