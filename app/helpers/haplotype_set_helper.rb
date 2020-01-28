module HaplotypeSetHelper

	MatchBlock = Struct.new(:assembly, :chromosome, :start, :end, :block_no, :chr_length, :blocks, :merged_block) do 
		def length
			self.start - self.end
		end

		def to_r
			"#{chromosome}:#{start}-#{self.end}"
		end

		def overlap(other)
			ret = other.assembly == self.assembly
			ret &= other.chromosome == self.chromosome
			ret &= (other.start.between?(self.start, self.end) or other.end.between?(self.start, self.end) )
			ret
		end

		def <=>(other)
    		return self.assembly <=> other.assembly if self.assembly != other.assembly 
    		return self.chromosome <=> other.chromosome if self.chromosome != other.chromosome 
    		return self.start <=> other.start if self.start != other.start 
    		return self.end <=> other.end
  		end
	end

	def self.features_to_blocks(features, max_gap:500, min_features: 20, block_no: 0, asm:"")
		prev_parsed = nil
		start = features.first
		prev = nil
		ret = []
		gene_count_in_block = 0
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
				ret << MatchBlock.new(asm, f.chr, start.from, prev.to, "#{block_no}.#{1+ret.size}", 
					f.region.scaffold.length, block_no, nil) if gene_count_in_block > min_features
				start = f   
				gene_count_in_block = 0
			end
			
			prev =f
			prev_parsed = parsed
		end
		f = prev 
		ret << MatchBlock.new(asm, f.chr, start.from, prev.to, "#{block_no}.#{1+ret.size}", 
			f.region.scaffold.length, block_no, nil) if f and gene_count_in_block > min_features

		#puts ret.size
		#puts"--------------"	    
		ret 
	end


	def self.find_base_blocks(block, max_gap:1000, min_features: 10)
		prev_parsed = nil

		features = HaplotypeSetHelper.find_reference_features_in_block(block)
		start = features.first
		prev = nil
		ret = []
		gene_count_in_block = 0
		features.each_with_index do |f,i |
			gene_count_in_block += 1
			parsed = BioPangenome.parseTranscript f.name
			prev_parsed = parsed unless prev_parsed
			prev = f  unless prev
			ok = prev_parsed.count_int + max_gap >= parsed.count_int       

			if not ok 
				ret << MatchBlock.new(f.asm.name, f.chr, start.from, prev.to, block.block_no, 
					f.region.scaffold.length, block.blocks, block) if gene_count_in_block > min_features
				start = f   
				gene_count_in_block = 0
			end
			
			prev =f
			prev_parsed = parsed
		end
		f = prev 
		ret << MatchBlock.new(f.asm.name, f.chr, start.from, prev.to, block.block_no, 
			f.region.scaffold.length, block.blocks, block) if f and gene_count_in_block > min_features

		#puts ret.size
		#puts"--------------"	    
		ret 
	end


	def self.find_calculated_block(haplotype_set, chromosome: '5A' )
		query = "SELECT  assemblies.name as assembly, scaffolds.name as chromosome, scaffolds.length as chr_length, regions.start, regions.end, block_no 
		FROM `haplotype_blocks` INNER JOIN `regions` ON `regions`.`id` = `haplotype_blocks`.`region_id` 
		INNER JOIN `assemblies` ON `assemblies`.`id` = `haplotype_blocks`.`assembly_id` 
		INNER JOIN `haplotype_sets` ON `haplotype_sets`.`id` = `haplotype_blocks`.`haplotype_set_id` 
		INNER JOIN `regions` `regions_haplotype_blocks_join` ON `regions_haplotype_blocks_join`.`id` = `haplotype_blocks`.`region_id` 
		INNER JOIN `scaffolds` ON `scaffolds`.`id` = `regions_haplotype_blocks_join`.`scaffold_id` 
		INNER JOIN `chromosomes` on `chromosomes`.`id` = `scaffolds`.`chromosome`
		WHERE haplotype_sets.name = ? and chromosomes.name = ?  
		ORDER BY block_no;"
		Region.find_by_sql([query, haplotype_set, chromosome])
	end

	def self.find_all_calculated_blocks(haplotype_set )
		query = "SELECT  assemblies.name as assembly, scaffolds.name as chromosome, scaffolds.length as chr_length, regions.start, regions.end, block_no 
		FROM `haplotype_blocks` INNER JOIN `regions` ON `regions`.`id` = `haplotype_blocks`.`region_id` 
		INNER JOIN `assemblies` ON `assemblies`.`id` = `haplotype_blocks`.`assembly_id` 
		INNER JOIN `haplotype_sets` ON `haplotype_sets`.`id` = `haplotype_blocks`.`haplotype_set_id` 
		INNER JOIN `regions` `regions_haplotype_blocks_join` ON `regions_haplotype_blocks_join`.`id` = `haplotype_blocks`.`region_id` 
		INNER JOIN `scaffolds` ON `scaffolds`.`id` = `regions_haplotype_blocks_join`.`scaffold_id` 
		INNER JOIN `chromosomes` on `chromosomes`.`id` = `scaffolds`.`chromosome`
		WHERE haplotype_sets.name = ? 
		ORDER BY block_no;"
		Region.find_by_sql([query, haplotype_set])
	end


	def self.find_longest_block_sql(haplotype_set)
		query = "  WITH hap_regions AS (
 SELECT  assemblies.name as assembly_name, scaffolds.name as chromosome, scaffolds.length as chr_length, regions.start, regions.end, haplotype_blocks.block_no,
 regions.start as lower_bound,
 MAX(regions.end) OVER (PARTITION BY assemblies.name, scaffolds.name ORDER BY regions.start, regions.end) AS upper_bound
 FROM `haplotype_blocks` INNER JOIN `regions` ON `regions`.`id` = `haplotype_blocks`.`region_id` 
 INNER JOIN `assemblies` ON `assemblies`.`id` = `haplotype_blocks`.`assembly_id` 
 INNER JOIN `haplotype_sets` ON `haplotype_sets`.`id` = `haplotype_blocks`.`haplotype_set_id` 
 INNER JOIN `regions` `regions_haplotype_blocks_join` ON `regions_haplotype_blocks_join`.`id` = `haplotype_blocks`.`region_id` 
 INNER JOIN `scaffolds` ON `scaffolds`.`id` = `regions_haplotype_blocks_join`.`scaffold_id` WHERE (haplotype_sets.name = ? )
),
b AS (
   SELECT *, lag(upper_bound) OVER (PARTITION BY assembly_name, chromosome, chr_length ORDER BY hap_regions.start, hap_regions.end) < lower_bound OR NULL AS step
   FROM   hap_regions
  ),
  c AS (
   SELECT *, count(step) OVER (PARTITION BY assembly_name, chromosome,chr_length ORDER BY b.start, b.end) AS grp
   FROM   b
)
SELECT assembly_name as assembly, chromosome, grp,
MIN(lower_bound) as `start`, MAX(upper_bound) as `end` , 
 MAX(upper_bound) - MIN(lower_bound) as block_len , chr_length,
@rownum:=@rownum+1 as block_no
FROM c , (SELECT @rownum:=0) r
GROUP BY 
assembly_name, chromosome, grp, chr_length
ORDER BY assembly_name,  chromosome,  MIN(lower_bound), MAX(upper_bound);
 "
 	Region.find_by_sql([query, haplotype_set])
	end

	def self.to_blocks(blocks)
		ret = Array.new
		blocks.each do |e|  
			ret << MatchBlock.new(e.assembly, e.chromosome,e.start.to_i, e.end.to_i, e.block_no.to_i, e.chr_length.to_i, [], nil)
		end
		ret

	end

	def self.find_reference_features_in_block(block, type:'gene', reference: true, assembly:'IWGSCv1.1')

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
		query = "SELECT `features`.*
FROM `regions`
JOIN `scaffolds` on `regions`.`scaffold_id` = `scaffolds`.`id`
JOIN `assemblies` on `scaffolds`.`assembly_id` = `assemblies`.`id`
join `features` on `regions`.`id` = `features`.`region_id`
join feature_types on feature_types.id = features.feature_type_id
WHERE assemblies.name  = ?
AND regions.start >= ?
and regions.end <= ?
and scaffolds.name = ?
and feature_types.name = ?
;"
	Feature.find_by_sql([query, block.assembly, block.start, block.end, block.chromosome, type] )
	end


	def self.find_genes_in_blocks(blocks, target: 'IWGSCv1.1' )
		target_asm = FeatureHelper.find_assembly(target)
	end

	def self.scale_blocks(blocks, target: "lancer")
    puts "scaling"
    ret = []
    puts "__________________________"

    prev_asm = nil
    features = []
    seen_blcks = []
    block_id = nil
    blocks.each_with_index do |block, i|
      features += HaplotypeSetHelper.find_reference_features_in_block(block, type: 'gene')
      seen_blcks <<  block.block_no
      if prev_asm && block_id == block.block_no
        
        if target
          features = FeatureHelper.find_mapped_features(features, assembly: target)
        end

        features.sort!.uniq
        
        ret << HaplotypeSetHelper.features_to_blocks(features,block_no: block_id, asm:prev_asm)
        ret << HaplotypeSetHelper.features_to_blocks(features,block_no: block_id, asm:block.assembly)
        features.clear
        #break if i > 10
      end
      block_id = block.block_no
      prev_asm = block.assembly
      #m_blocks = HaplotypeSetHelper.find_base_blocks(block)
      #ret << m_blocks
    end

    ret.flatten!
    puts "........."
    ret 
  end


	def self.find_longest_block(blocks)
		longest_block         = MatchBlock.new(nil, nil, 0,0,0,0, [])
		current_longest_block = MatchBlock.new(nil, nil, 0,0,0,0, [])
		prev_block = nil
		blocks.each do |e|
			next unless e.merged_block.nil?
			
			if prev_block.nil?
				prev_block = e
				next
			end

			if e.overlap(current_longest_block)
				puts ""
			else
				puts ""
			end


			prev_block = e 
		end

	end
end
