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
end
