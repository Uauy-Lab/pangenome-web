module ApplicationHelper

	def all_species
		Species.all.map{|s| [s.name,s.id]}
	end

	def session_species
		if session[:selected_species].nil? 
			session[:selected_species] = Species.all.first.id 
		end

		Species.find(session[:selected_species])

	end

	def selected_species_chromosomes
		ret = Chromosome.where(species_id: session_species["id"]).map{|c| [c.name, c.id]} 
		ret
	end

	def session_chromosome(chr: nil)
		if chr
			session[:selected_chromosome] = Chromosome.find_by(name: chr).id
		end

		unless session[:selected_chromosome]
			session[:selected_chromosome] = selected_species_chromosomes.first[1]
		end

		ret = Chromosome.find(session[:selected_chromosome])
		ret
	end


end
