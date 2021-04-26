module ApplicationHelper

	def all_species
		Species.all.map{|s| [s.name,s.id]}
	end

	def session_species
		session[:selected_species] = Species.all.first.id if session[:selected_species].nil? 
		Species.find(session[:selected_species])
	end

	def selected_species_chromosomes
		Chromosome.where(species_id: session_species["id"]).map{|c| [c.name, c.id]} 
	end

	def session_chromosome(chr: nil)
		session[:selected_chromosome] = Chromosome.find_by(name: chr).id if chr
		session[:selected_chromosome] = selected_species_chromosomes.first[1] unless session[:selected_chromosome]
		Chromosome.find(session[:selected_chromosome])
	end

	def selected_chromosome_hap_sets()
		sp = session_species
		chr = session_chromosome
		HaplotypeSetHelper.find_hap_sets(species: sp.name, chr: chr.name).map{
			 |c| [c.description, c.name]} 
	end

	def session_hap_set(hap_set:nil)
		puts "......................................................hs"
		puts(hap_set)
		session[:selected_hap_set] = HaplotypeSet.find_by(name: hap_set).id if hap_set
		unless session[:selected_hap_set] 
			session[:selected_hap_set] = HaplotypeSet.find_by(
				name: selected_chromosome_hap_sets.last[1]
			).id
			puts "...."
			puts session[:selected_hap_set] 
		end
		return HaplotypeSet.find(session[:selected_hap_set])
	end
end
