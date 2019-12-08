module HaplotypeSetHelper
	def self.find_calculated_block(block_name)
		query = HaplotypeBlock.joins(:region,:assembly,:haplotype_set,:scaffold)
		#query = query.select(' assemblies.name as assembly, scaffolds.name as chromosome, regions.start, regions.end, block_no')
		query = query.where('haplotype_sets.name=?',[block_name])
		query
	end
end
