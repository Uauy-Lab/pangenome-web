module IBSpyHelper

	def self.load(species, assembly,library, line, analysis, description,path)
		species  = Species.find_species(species)
		assembly = species.assembly(assembly)
		raise "Assembly #{assembly} not found in #{species}" if assembly == nil
		lib = Library.find_by_line(library, 
			line:line, 
			species:species)
		puts lib.inspect
		lib.save
		ka = KmerAnalysis.new()
		ka.line = lib.line
		ka.library = lib
		ka.assembly = assembly
		ka.name = analysis
		ka.description = description
		ka.init_scores

		i = 0
		#"total_kmers":"97467" "observed_kmers":"21601" "variations":"1239" "kmer_distance":"62301"

		

		CSV.foreach(path, col_sep:"\t",headers:true) do |row|
			scaff_name = row['seqname']
			#puts row.inspect
			scaff = assembly.chromosome(scaff_name)
			#scaff = Scaffold.find_by(name: scaff_name, assembly_id: asm)
			throw "Scaff #{scaff_name} not found in assembly #{assembly.name} #{row.inspect}" if scaff.nil?
			#puts scaff
			first = row["start"].to_f.to_i
			last  = row["end"].to_f.to_i
			region =  Region.find_or_create_by(scaffold: scaff, start: first, end:last )
			#puts region
			perc_kmers = 100 * row["observed_kmers"].to_f / row["total_kmers"].to_f 
			#puts "perc_kmers: #{perc_kmers}"
			RegionScore.add(region, ka.score("total_kmers"), row["total_kmers"],ka)
			RegionScore.add(region, ka.score("observed_kmers"), row["observed_kmers"],ka)
			RegionScore.add(region, ka.score("variations"), row["variations"],ka)
			RegionScore.add(region, ka.score("kmer_distance"), row["kmer_distance"],ka)
			RegionScore.add(region, ka.score("perc_kmers"), perc_kmers,ka)
			#i += 1 
			#break if i > 10
		end
		#puts ka.inspect
		#puts "......"
		#puts ka.score_type
		#puts ka.scores.inspect
		ka.save!

		#raise "We didn't save! we are testing"

	end


end