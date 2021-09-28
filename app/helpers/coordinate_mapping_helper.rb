module CoordinateMappingHelper


	def self.coordinate_mapping_in_regin(scaffold, start, end_, align_mapping_set)
		#mappings = AlignMapping.in_region(scaffold, start, end_, align_mapping_set)
		mappings = AlignMapping.in_region_same_scaffold(scaffold, start, end_, align_mapping_set)
		mapped_regions = Set.new
		mappings.each do |am|
			mapped_regions << am.mapped_block_id
		end
		mappings  = AlignMapping.where(align_mapping_set: align_mapping_set ).where(mapped_block: mapped_regions)
		mr      = Region.new
		mr.id    = 0
		mrs      = ""
		mr_simple = ""
		mr_asm   = ""
		blocks_csv = []
		blocks_csv << ["assembly", "reference", "chromosome", "start", "end", "block_no", "region_id", "mapping_region_id"].join(",")
		mappings.each do |am|
			region = am.region
			rs = Scaffold.cached_from_id(region.scaffold_id)
			if mr.id != am.mapped_block_id
				mr = am.mapped_block
				mrs = Scaffold.cached_from_id(mr.scaffold_id)
				mr_simple = "#{mrs.name}:#{mr.start}-#{mr.end}"
				mr_asm = mrs.assembly.name
			end
			b = [ mr_asm,rs.assembly.name, region.name, region.start, region.end , mr_simple, region.id, mr.id ]
			blocks_csv << b.join(",")
		end
		return blocks_csv


	end
end