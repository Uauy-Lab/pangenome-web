class Species < ActiveRecord::Base
	has_many :chromosomes
	has_many :lines
	def assemblies
		@assemblies = Rails.cache.fetch("species/#{self.name}/assemblies") do
			
			query = "select distinct assemblies.*
			from 
			species 
			JOIN chromosomes on chromosomes.species_id = species.id
			JOIN scaffolds on scaffolds.chromosome = chromosomes.id
			JOIN assemblies on assemblies.id = scaffolds.assembly_id 
			WHERE species.name = ?;"

			asms = Hash.new 
			Assembly.find_by_sql([query, self.name]).each do |asm|
				asms[asm.name] = asm 
			end
			asms
		end
		return @assemblies.values
	end

	def assembly(name)
		self.assemblies unless @assemblies
		return @assemblies[name]
	end

	def cannonical_assembly
		assemblies.each do |asm|
			return asm if asm.is_cannonical
		end
	end

	def self.find_species(name)
		begin
	      species = Species.find_or_create_by(name: name)
	    rescue ActiveRecord::RecordNotUnique
	      retry
	    end
	    return species
  	end
end
