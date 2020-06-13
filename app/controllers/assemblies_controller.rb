require 'bio-pangenome'

class AssembliesController < ApplicationController
	def coordinate_mappig
		respond_to do |format|
			format.json do
				render :json => { test: "ok" }
      		end
    	end
	end
end