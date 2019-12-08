module SearchHelper

	def find_calculated_block(block_name: "6A_test")
		query = HaplotypeBlock.joins(:region,:assembly,:haplotype_set,:scaffold).
		query = query.select(' assemblies.name, scaffolds.name as chromosome, regions.start, regions.end, block_no')
		query = query.where('haplotype_sets.name=?',[block_name])

	end

end
