module FeatureHelper
	 @@features_in_asm = false
	 @@features_in_region = false

	def self.find_chromosome(name, species)
		@@chromosomes = Hash.new unless  defined? @@chromosomes
		full_name="#{species.name}.#{name}"
		return  @@chromosomes[full_name] if  @@chromosomes[full_name]
		puts "Loading chr #{full_name}"
		chromosome = Chromosome.find_by(name: name, species: species)
		unless chromosome
			chromosome = Chromosome.new
			chromosome.name = name
			chromosome.species = species
			chromosome.save!
		end
		return  @@chromosomes[full_name]  = chromosome
		return chromosome
	end

	def self.find_assembly(name)
		@@assemblies = Hash.new unless defined? @@assemblies
		return @@assemblies[name] if @@assemblies[name]
		begin
			@@assemblies[name] = Assembly.find_or_create_by(name: name)
		rescue ActiveRecord::RecordNotUnique
			retry
		end
		return @@assemblies[name]
	end


	def self.find_features_in_assembly(assembly, feature_type, column: :region_id)
		@@features_in_asm = Hash.new unless @@features_in_asm
		name = "#{assembly}_#{feature_type}"
    	return @@features_in_asm[name] if @@features_in_asm[name] 
		query = "SELECT 
		features.*
		FROM assemblies 
		JOIN scaffolds  on scaffolds.assembly_id = assemblies.id
		JOIN regions on regions.scaffold_id = scaffolds.id 
		JOIN features on features.region_id = regions.id
		JOIN feature_types on features.feature_type_id = feature_types.id
		WHERE  feature_types.name = ? 
		AND assemblies.name = ?" ;

		ret = Hash.new

		Feature.find_by_sql([query, feature_type, assembly]).each do |f|
			ret[f.name] = f[column]
		end
		@@features_in_asm[name] = ret
		@@features_in_asm[name]
	end

	def self.find_features_in_region(assembly, feature_type, chr, start, finish, only_mapped: false )
		@@features_in_region = Hash.new unless @@features_in_region
		name = "#{assembly}_#{feature_type}:#{chr}:#{start}-#{finish}"
    	return @@features_in_region[name] if @@features_in_region[name] 

    	extra = ""
    	extra += "AND (features.id IN (select distinct feature_mappings.other_feature  FROM feature_mappings) 
        OR features.id IN (select distinct feature_mappings.feature_id  FROM feature_mappings) )" if only_mapped
		query = "SELECT 
		features.*
		FROM assemblies 
		JOIN scaffolds  on scaffolds.assembly_id = assemblies.id
		JOIN regions on regions.scaffold_id = scaffolds.id 
		JOIN features on features.region_id = regions.id
		JOIN feature_types on features.feature_type_id = feature_types.id
		WHERE  feature_types.name = ? 
		AND assemblies.name = ? 
		AND scaffolds.name = ?
		AND regions.start >= ? 
		AND regions.end <= ? 
		#{extra}
		ORDER BY regions.start, regions.end ;"

		ret = Array.new

		Feature.find_by_sql([query, feature_type, assembly, chr, start, finish]).each do |f|
			ret << f
		end
		@@features_in_region[name] = ret
		@@features_in_region[name]
	end

	def self.insert_feature_mappings_sql(inserts, conn)
		adapter_type = conn.adapter_name.downcase.to_sym
		case adapter_type
		when :mysql
			sql = "INSERT  INTO feature_mappings  (`assembly_id`, `feature_id`, `chromosome_id`, `feature_mapping_set_id`, `other_feature`, `created_at`,`updated_at`) VALUES #{inserts.join(", ")}"
		when :mysql2 
			sql = "INSERT  INTO feature_mappings  (`assembly_id`, `feature_id`, `chromosome_id`, `feature_mapping_set_id`, `other_feature`, `created_at`,`updated_at`) VALUES #{inserts.join(", ")}"
		else
			raise NotImplementedError, "Unknown adapter type '#{adapter_type}'"
		end
		old_logger = ActiveRecord::Base.logger
		ActiveRecord::Base.logger = nil
		conn.execute sql 
		inserts.clear
		ActiveRecord::Base.logger = old_logger
	end

	def self.find_mapped_features(features, assembly:"lancer", reference: false)

		return [] if features.nil? or features.size == 0
		ids = features.map{|f| f.id}

		feature_id = "feature_id"
		other_feature = "other_feature"
		extra = ""
		unless reference
			asm = Assembly.find_by(name: assembly)
			feature_id = "other_feature"
			other_feature = "feature_id"
			extra = " AND assembly_id = #{asm.id} "
		end
		query = "	
		select features.*
		from feature_mappings 
		join feature_mapping_sets on feature_mappings.feature_mapping_set_id = feature_mapping_sets.id
		join features on feature_mappings.#{feature_id} = features.id
		where #{other_feature} in (#{ids.join(",")})
		#{extra}
		ORDER BY features.name;"
		Feature.find_by_sql([query] )
	end
end
