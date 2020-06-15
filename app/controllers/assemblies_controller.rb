require 'bio-pangenome'

class AssembliesController < ApplicationController
	before_action :assemblies_params

	def coordinate_mappig

		#species = 

		respond_to do |format|
			format.json do
				render :json => { test: "ok" }
      		end
    	end
	end

	private

	def assemblies_params
      params.require(:chr_name, :species).permit(:window_size)
    end

end