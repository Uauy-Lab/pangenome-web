class WellcomeController < ApplicationController



	def default
		@selected_species = getSelectedSpecies
		@species = Species.all.map{|s| [s.name,s.id]}
		@chromosomes = Chromosome.where(species_id: @selected_species["id"]).map{|c| [c.name, c.id]} 

	end
end
