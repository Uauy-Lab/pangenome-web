module AssembliesHelper

	def block_to_all(blocks, chromosomes_asm, cannonical_assembly, min_features: 10)
		ret = Array.new
		chromosomes_asm.each do |scaffold|
			asm = scaffold.assembly.name
			ret <<  HaplotypeSetHelper.scale_blocks(blocks, 
				target:asm, species: @species.name, min_features: min_features)
		end
		ret

	end

	def getRegionWindows(window_size: 1000000, min_features: 10)
		chromosomes_asm = Scaffold.where(chromosome: @chromosome)
		assembly_chr = []
		cannonical_assembly = @species.cannonical_assembly
		chromosomes_asm.each do |scaffold|
			steps = 1.step(to: scaffold.length, by:window_size)
			asm = scaffold.assembly.name
			reference = asm 
			blocks = []

			steps.each do |s|
				block_no = "#{reference}:#{s}"
				mb =  MatchBlock::MatchBlock.new(asm, 
					reference,
					scaffold.name, s, s + window_size - 1 , block_no, 
					scaffold.length, block_no, [])
				mb.end = scaffold.length if mb.end > scaffold.length
				#converted = block_to_all(mb, chromosomes_asm, cannonical_assembly)
				blocks << mb
			end

			#pseudomolecule_blocks = HaplotypeSetHelper.scale_blocks_to_pseudomolecue(blocks, species: @species.name, min_features: min_features)
			assembly_chr << block_to_all(blocks, chromosomes_asm, cannonical_assembly, min_features: min_features)
		end
		assembly_chr.flatten
	end
end