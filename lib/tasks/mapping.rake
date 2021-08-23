require 'bio'
require 'csv'

namespace :mappings do
	desc "Load alignment mapping from converted regions form merge_coordinates.rb"

	task :load_merged, [:filename] => :environment do |t, args|
		#rake mappings:load_merged[/Users/ramirezr/Dropbox/JIC/Haplotypes/20210813_coordinate_mapping/merged_in_windows__ws-100000_round-3_flank-50000.tsv.gz]    
		ActiveRecord::Base.transaction do
			aln_map_set = AlignMappingSet.find_or_create_by(name: args[:filename])
			Zlib::GzipReader.open(args[:filename]) do |stream|
				i = 0
				csv = CSV.new(stream, headers: true, col_sep: "\t")
				csv.each do |row| 
					#puts row.inspect
					region_id = Region.parse_and_find(row["block_no"])
					region    = Region.find_for_save(row["chromosome"], row["start"], row["end"])
					region.reverse! if row["orientation"] == "-"
					#puts region_id.inspect
					#puts region.inspect
					#i == 10
					aln = AlignMapping.new
					aln.region             = region 
					aln.align_mapping_set  = aln_map_set
					aln.mapped_block_id    = region_id
					i +=1 
					if i % 1000 == 0
						puts  "#{i}: #{row}"
						#raise "Testing!" if row["orientation"] == "-"
					end
					
				end
			end

		end

	end

end