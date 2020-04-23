module HaplotypeStatsHelper

	def self.export_haplotype_block_stats(out, out_missing,analysis_id , beds, species)

		species = Species.find_by(name: species)
		asm   = species.cannonical_assembly

		blocks = HaplotypeSetHelper.find_all_calculated_blocks(analysis_id)
		out.puts ["assembly","chromosome","start","end","block_no", 
        	"block_length", "genes", "genes_per_mbp", "regions"].join("\t")
        blocks.each do |e|
        	e = HaplotypeSetHelper::MatchBlock.new(
        	e.assembly, e.reference, e.chromosome, e.start, e.end, e.block_no, e.chr_length, [], nil)
        	e_scaled = HaplotypeSetHelper.scale_block(e, asm, species, target: asm.name)
        	mid_regs = []
        	e_scaled.each do |b|
        		regions = Bio::BED::getBlockRegion(beds,b)
        		mid = (b.start + b.end) / 2
        		mid_reg = Bio::BED::Bed4.new(b.chromosome, mid - 1, mid, b.block_no)
        		mid_regs << Bio::BED::getBlockRegion(beds,mid_reg)
        	end
        	out_missing.puts e.to_csv if e_scaled.size == 0
        	mid_regs.flatten!
        	mid_regs.uniq!
        	features = HaplotypeSetHelper.count_features_in_block(e, species:species.name)
        	genes_per_mbp = 1000000* features.count.to_f / e.length
        	out.puts [e.assembly, e.chromosome,e.start, e.end, e.block_no, 
        		e.length, features.count, genes_per_mbp, mid_regs.join("-") ].join("\t") 
        end
	end


	def self.export_haplotype_block_stats_in_points(hap_set, species, out, out_missing, size: 1000000)
		expires = 1.day
		puts species.inspect
		species = Species.find_by(name: species)
		puts species.inspect
		asm   = species.cannonical_assembly
		puts asm.inspect
		blocks = Rails.cache.fetch("blocks/#{species.name}/#{hap_set}", expires_in: expires) do
      		blocks = HaplotypeSetHelper.find_all_calculated_blocks(hap_set)
      		HaplotypeSetHelper.to_blocks(blocks)
    	end
    	blocks.sort!
    	out.puts ["assembly","chromosome","start","end","block_no", 
        	"block_length", "genes", "genes_per_mbp", "slice"].join("\t")
    	blocks.each_with_index do |block, i|
    		scaled = HaplotypeSetHelper.scale_block(block, asm, species, target: asm.name)
    		scaled.each do |b|
    			features_count = HaplotypeSetHelper.count_features_in_block(b).count
	    		genes_per_mbp = 1000000* features_count.to_f / b.length
	    		slices = b.slices(size: size)
	    		slices.each do |s| 
	    			out.puts [b.assembly, b.chromosome,b.start, b.end, b.block_no, 
        			b.length, features_count, genes_per_mbp, s].join("\t")
	    		end
	    		out_missing.puts b.to_csv if slices.size == 0
    		end
    		out_missing.puts block.to_csv if block.size == 0	
    	end
	end

	def self.export_haplotype_blocks_in_pseudomolecules(hap_set, species, out)
		expires = 1.day
		puts species.inspect
		species = Species.find_by(name: species)
		puts species.inspect
		blocks = Rails.cache.fetch("blocks/#{species.name}/#{hap_set}", expires_in: expires) do
      		blocks = HaplotypeSetHelper.find_all_calculated_blocks(hap_set)
      		HaplotypeSetHelper.to_blocks(blocks)
    	end
    	blocks = Rails.cache.fetch("blocks/#{species.name}/#{hap_set}/pseudomolecules", expires_in: expires) do
      		blocks = HaplotypeSetHelper.scale_blocks_to_pseudomolecue(blocks, species: species.name)
      		blocks.sort!
    	end
    	out.puts ["assembly","reference","chromosome","start","end","block_no", 
        	"block_length", "chr_length"].join("\t")
    	blocks.each_with_index do |b|
    		out.puts [b.assembly, b.reference, b.chromosome,b.start, b.end, b.block_no, 
        			b.length, b.chr_length].join("\t")
    	end
	end
end	
