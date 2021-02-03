module HaplotypeSetHelper	
	def self.features_to_blocks(features, max_gap:2000, min_features: 20, 
		block_no: 0, asm:"", reference:"", allow_small_blocks: true)
		prev_parsed = nil
		start = features.first
		prev = nil
		ret = []
		all = []
		gene_count_in_block = 0
		n = 0
		features.each_with_index do |f,i |
			gene_count_in_block += 1
			parsed = nil
			begin
				parsed = BioPangenome.parseTranscript f.name
			rescue Exception => e
				parsed = BioPangenome.parsePGSBTranscript f.name
			end

			prev_parsed = parsed unless prev_parsed
			prev = f  unless prev
			ok = prev_parsed.count_int + max_gap >= parsed.count_int       

			if not ok 
				mb =  MatchBlock::MatchBlock.new(asm, reference,f.chr, start.from, prev.to, "#{block_no}", 
						f.region.scaffold.length, block_no, [start, prev])
				ret << mb if gene_count_in_block > min_features 
				all << mb
				start = f   
				gene_count_in_block = 0
			end
			
			prev =f
			prev_parsed = parsed
		end
		f = prev 
		if prev
			mb =  MatchBlock::MatchBlock.new(asm, reference, f.chr, start.from, prev.to, "#{block_no}", 
			f.region.scaffold.length, block_no, [start,f]) 
			ret << mb if gene_count_in_block > min_features
			all << mb
		end
		if allow_small_blocks and ret.size == 0
			l_max = all.max_by(&:length) 
			ret << l_max unless l_max.nil?
		end
		ret 
	end


	# def self.find_base_blocks(block, max_gap:1000, min_features: 10)
	# 	prev_parsed = nil

	# 	features = HaplotypeSetHelper.find_reference_features_in_block(block)
	# 	start = features.first
	# 	prev = nil
	# 	ret = []
	# 	gene_count_in_block = 0
	# 	features.each_with_index do |f,i |
	# 		gene_count_in_block += 1
	# 		parsed = BioPangenome.parseTranscript f.name
	# 		prev_parsed = parsed unless prev_parsed
	# 		prev = f  unless prev
	# 		ok = prev_parsed.count_int + max_gap >= parsed.count_int       

	# 		if not ok 
	# 			ret << MatchBlock::MatchBlock.new(f.asm.name, f.chr, start.from, prev.to, block.block_no, 
	# 				f.region.scaffold.length, block.blocks, block) if gene_count_in_block > min_features
	# 			start = f   
	# 			gene_count_in_block = 0
	# 		end
			
	# 		prev =f
	# 		prev_parsed = parsed
	# 	end
	# 	f = prev 
	# 	ret << MatchBlock::MatchBlock.new(f.asm.name, f.chr, start.from, prev.to, block.block_no, 
	# 		f.region.scaffold.length, block.blocks, block) if f and gene_count_in_block > min_features
	# 	ret 
	# end

	def self.find_calculated_block(haplotype_set, chromosome: '5A', species: "Wheat" )
		query = "SELECT  assemblies.name as assembly,
			ref.name as reference, 
			scaffolds.name as chromosome, 
			scaffolds.length as chr_length, 
			regions.start, 
			regions.end, block_no ,
			haplotype_sets.name as hap_set
	FROM species
		JOIN chromosomes on chromosomes.species_id = species.id
		JOIN scaffolds on chromosomes.id = scaffolds.chromosome
		JOIN regions on regions.scaffold_id = scaffolds.id
		JOIN haplotype_blocks on haplotype_blocks.region_id = regions.id
		JOIN haplotype_sets on haplotype_sets.id = haplotype_blocks.haplotype_set_id
		JOIN assemblies on assemblies.id = haplotype_blocks.assembly_id	
		JOIN assemblies as ref on ref.id = haplotype_blocks.reference_assembly
		WHERE haplotype_sets.name = ? and chromosomes.name = ?  and species.name = ?
		ORDER BY block_no;"
		
		Rails.cache.fetch("blocks/#{species}/#{chromosome}/#{haplotype_set}") do
			tmp_b = Region.find_by_sql([query, haplotype_set, chromosome, species])
			self.to_blocks(tmp_b)
		end
	end

	def self.find_all_calculated_blocks(haplotype_set )
		query = "SELECT  
		assemblies.name as assembly, r_assembly.name as reference ,
		scaffolds.name as chromosome, scaffolds.length as chr_length, regions.start, regions.end, block_no 
		FROM `haplotype_blocks` INNER JOIN `regions` ON `regions`.`id` = `haplotype_blocks`.`region_id` 
		INNER JOIN `assemblies` ON `assemblies`.`id` = `haplotype_blocks`.`assembly_id` 
		INNER JOIN `haplotype_sets` ON `haplotype_sets`.`id` = `haplotype_blocks`.`haplotype_set_id` 
		INNER JOIN `regions` `regions_haplotype_blocks_join` ON `regions_haplotype_blocks_join`.`id` = `haplotype_blocks`.`region_id` 
		INNER JOIN `scaffolds` ON `scaffolds`.`id` = `regions_haplotype_blocks_join`.`scaffold_id` 
		INNER JOIN `chromosomes` on `chromosomes`.`id` = `scaffolds`.`chromosome`
		INNER JOIN `assemblies` as r_assembly ON r_assembly.id = haplotype_blocks.reference_assembly
		WHERE haplotype_sets.name = ? 
		ORDER BY block_no;"

		Rails.cache.fetch("blocks/#{haplotype_set}") do
			tmp_b = Region.find_by_sql([query, haplotype_set])
			self.to_blocks(tmp_b)
		end
	end

	def self.find_calculated_block_pseudomolecules(haplotype_set, chromosome: '5A', species: "Wheat" )
		Rails.cache.fetch("blocks/#{species}/#{chromosome}/#{haplotype_set}/pseudomolecules") do
			blocks = HaplotypeSetHelper.find_calculated_block(haplotype_set, chromosome:chromosome, species: species)
			tmp = HaplotypeSetHelper.scale_blocks_to_pseudomolecue(blocks, species: species)
			tmp.sort!
 		end
	end


	def self.find_haplotype_coordinates(haplotype_set, target: ["IWGSCv1.1"]) 
		Rails.cache.fetch("blocks/#{haplotype_set}/#{target}") do
			blocks   = HaplotypeSetHelper.find_all_calculated_blocks(haplotype_set)
			s_blocks = HaplotypeSetHelper.scale_blocks(blocks, target: target)
			s_blocks.sort!
		end
	end

	def self.to_blocks(blocks)
		ret = Array.new
		blocks.each do |e|  
			e.end = e.chr_length if e.end > e.chr_length
			ret << MatchBlock::MatchBlock.new(e.assembly, e.reference, e.chromosome,e.start.to_i, e.end.to_i, e.block_no, e.chr_length.to_i, [], nil)
		end
		ret
	end

	def self.find_reference_features_in_block(block, type:'gene', reference: true, assembly:'IWGSCv1.1', species: "Wheat")
		feature_id = "feature_id"
		other_feature = "other_feature"
		unless reference
			feature_id = "other_feature"
			other_feature = "feature_id"
		end
		query = "	
		select features.*
		from feature_mappings 
		join feature_mapping_sets on feature_mappings.feature_mapping_set_id = feature_mapping_sets.id
		join features on feature_mappings.#{feature_id} = features.id
		where #{other_feature} in (
		SELECT `features`.id  
		FROM `regions`
		JOIN `scaffolds` on `regions`.`scaffold_id` = `scaffolds`.`id`
		JOIN `assemblies` on `scaffolds`.`assembly_id` = `assemblies`.`id`
		join `features` on `regions`.`id` = `features`.`region_id`
		join feature_types on feature_types.id = features.feature_type_id
		WHERE 
		regions.`start` >= ?
		and regions.`end` <= ?
		and scaffolds.`name` = ?
		and feature_types.`name` = ?
		)
		ORDER BY features.name;"
		Feature.find_by_sql([query, block.start, block.end, block.chromosome, type] )
	end

	def self.find_features_in_block(block, type: 'gene')
		Feature.find_by_features_in_block(block, type: type)
	end

	def self.count_features_in_block(block, type: 'gene')
		Feature.count_features_in_block(block, type: type)
	end

	def self.find_hap_sets(species: "Wheat", chr: "1A")
		query = "SELECT * from haplotype_sets WHERE id in 
(
SELECT  haplotype_sets.id as id  
FROM species
JOIN chromosomes on chromosomes.species_id = species.id
JOIN scaffolds on chromosomes.id = scaffolds.chromosome
JOIN regions on regions.scaffold_id = scaffolds.id
JOIN haplotype_blocks on haplotype_blocks.region_id = regions.id
JOIN haplotype_sets on haplotype_sets.id = haplotype_blocks.haplotype_set_id
WHERE chromosomes.name = ?
and species.name = ?
group by haplotype_sets.id ) ;"
		HaplotypeSet.find_by_sql([ query, chr, species] )
	end

	def self.scale_block(block, cannonical_assembly, species, target:"IWGSCv1.1",  min_features: 10)
		return [ block.clone ] if block.reference == target
		#print("scaling;")
		#print(block)
		features = []
		if block.reference != cannonical_assembly.name
			features = HaplotypeSetHelper.find_reference_features_in_block(block, type: 'gene')
		else
			features = HaplotypeSetHelper.find_features_in_block(block, type:'gene')
		end
		if target != cannonical_assembly.name
			target_asm = species.assembly(target)
			features = FeatureHelper.find_mapped_features(features, assembly: target_asm)
		end
		features.sort!.uniq!
		HaplotypeSetHelper.features_to_blocks(features,block_no: block.block_no, asm:block.assembly, reference: target, min_features: min_features)
	end

	def self.update_cache_status(id, current, total)
		puts "#{id}:\t#{current}\t#{total}"
	end

	def self.scale_blocks(blocks, target:"IWGSCv1.1", species: "Wheat", min_features: 10,  cache_id: nil)
		ret = []
		sp = Species.find_by(name: species)
		cannonical_assembly = sp.cannonical_assembly
		blocks.each_with_index do |block, i|
			ret  << scale_block(block, cannonical_assembly, sp, target: target, min_features: min_features)
			update_cache_status(cache_id, current, total) if cache_id and i % 100 == 0
			#puts "`````"
			#puts ret
		end
		ret.flatten!
  		return  self.to_blocks ret 
	end

	def self.scale_blocks_to_pseudomolecue(blocks, species: "Wheat", min_features: 10)
		ret = []
		sp = Species.find_by(name: species)
		cannonical_assembly = sp.cannonical_assembly
		blocks.each_with_index do |block, i|
			asm = sp.assembly(block.assembly)
			if asm.is_pseudomolecule
				ret << block
			else 
				ret  << scale_block(block, cannonical_assembly, sp, target: cannonical_assembly.name, min_features: min_features)
			end
		end
		ret.flatten!
  		return ret 
	end
end
