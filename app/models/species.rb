class Species < ActiveRecord::Base

	def assemblies
		query = "select distinct assemblies.*
		from 
		species 
		JOIN chromosomes on chromosomes.species_id = species.id
		JOIN scaffolds on scaffolds.chromosome = chromosomes.id
		JOIN assemblies on assemblies.id = scaffolds.id
		WHERE species.name = ?;"
		Assembly.find_by_sql([query, self.name])
	end

	def assembly(name)
		@assemblies = Hash.new unless @assemblies
		return @assemblies[name] if @assemblies[name]

		query = "select distinct assemblies.*
		from 
		species 
		JOIN chromosomes on chromosomes.species_id = species.id
		JOIN scaffolds on scaffolds.chromosome = chromosomes.id
		JOIN assemblies on assemblies.id = scaffolds.id
		WHERE species.name = ? AND assemblies.name = ?;"
		@assemblies[name]  = Assembly.find_by_sql([query, self.name, name]).first
		@assemblies[name]  
	end

	def cannonical_assembly
		query = "select distinct assemblies.*
		from 
		species 
		JOIN chromosomes on chromosomes.species_id = species.id
		JOIN scaffolds on scaffolds.chromosome = chromosomes.id
		JOIN assemblies on assemblies.id = scaffolds.id
		WHERE species.name = ? AND is_cannonical;"
		Assembly.find_by_sql([query, self.name]).first
	end


end
