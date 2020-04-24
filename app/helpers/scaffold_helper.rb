module ScaffoldHelper

	def self.parse_wheat_chromosome(contig)
		chr = nil
		begin
			chr = nil
			arr = contig.split("_")
			if(arr.size == 5)
				chr=arr[2][0,2]
			elsif arr.size == 3 and arr[2] == "scaffold"
				chr=arr[0]
			elsif arr.size == 3 and arr[2] = ""
				chr = arr[0].gsub("chr","")
			elsif arr.size == 1
				chr = arr[0].gsub("chr","")
			else
				$stderr.puts "unable to parse! #{contig}"
			end
		rescue
			$stderr.puts "unable to parse! #{contig}"
		end
		return chr
	end

	def self.parse_brassica_napus_chromosome(contig)
		chr = "Un"
		md = /([AC][[:digit:]][[:digit:]]$)/.match(contig)
		chr = md[0] unless md.nil?
		return chr
	end

	def self.parse_identity_chromosome(contig)
		contig
	end

	def self.insert_scaffolds_from_stream(stream,species, assembly, conn)
		parser = ScaffoldHelper.method("parse_identity_chromosome")
		begin
			parser = ScaffoldHelper.method("parse_#{species.gsub(" ", "_").downcase}_chromosome")
		rescue
			$stderr.puts "No parser for '#{species}'. Using sequence name as chromosome"
		end

		species = Species.find_species(species)
		assembly = FeatureHelper.find_assembly(assembly)
		puts "Assembly: #{assembly}"
		count=0
		generated_str = ""
		inserts = Array.new
		csv = CSV.new(stream, :headers => false, :col_sep => "\t")
		csv.each do |row|
			inserts.push  prepare_insert_scaffold_sql(row[0], row[1], species, assembly, parser)
			count += 1
			if count % 10000 == 0
				puts "Loaded #{count} scaffolds" 
				insert_scaffold_sql(inserts, conn)
			end
		end
		puts "Loaded #{count} scaffolds" 
		insert_scaffold_sql(inserts, conn)
	end

	def self.prepare_insert_scaffold_sql(contig, length, species, assembly, parser)
		chr	= parser.call(contig)
		chromosome = FeatureHelper.find_chromosome(chr,species)
		str="('#{contig}',#{length},#{chromosome.id},#{assembly.id},NOW(),NOW())"
		return str
	end

	def self.insert_scaffold_sql(inserts, conn)
		adapter_type = conn.adapter_name.downcase.to_sym
		case adapter_type
		when :mysql2 
			sql = "INSERT IGNORE INTO scaffolds (`name`,`length`, `chromosome`, `assembly_id`,`created_at`, `updated_at`) VALUES #{inserts.compact.join(", ")}"

		when :mysql 
			sql = "INSERT IGNORE INTO scaffolds (`name`,`length`, `chromosome`, `assembly_id`,`created_at`, `updated_at`) VALUES #{inserts.compact.join(", ")}"
		when :sqlite
			sql = "INSERT IGNORE INTO scaffolds (`name`,`length`, `chromosome`, `assembly_id`,`created_at`, `updated_at`) VALUES #{inserts.compact.join(", ")}"
		when :postgresql
			sql = "INSERT INTO scaffolds (name, length, chromosome, assembly_id, created_at, updated_at) VALUES #{inserts.compact.join(", ")} ON CONFLICT DO NOTHING"
		else
			raise NotImplementedError, "Unknown adapter type '#{adapter_type}'"
		end
		conn.execute sql
		inserts.clear
	end


end