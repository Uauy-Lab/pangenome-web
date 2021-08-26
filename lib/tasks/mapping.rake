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
				block_no = ""
				region_id = 0
				csv.each do |row| 
					#puts row.inspect
					if block_no != row["block_no"]
						region_id = Region.parse_and_find(row["block_no"])
						block_no = row["block_no"]
					end
					start = row["start"]
					last  =  row["end"]
					if row["orientation"] == "-"
						start =  row["end"]
						last  =  row["start"]
					end

					region = Region.find_for_save(
						row["chromosome"],
						start, 
						last)
					region.reverse! if row["orientation"] == "-"
					#puts region_id.inspect
					#puts region.inspect
					#i == 10
					aln = AlignMapping.new
					aln.region             = region 
					aln.align_mapping_set  = aln_map_set
					aln.mapped_block    = region_id
					i +=1 
					if i % 10000 == 0
						puts  "#{i}: #{row}"
						#raise "Testing!" if row["orientation"] == "-"
					end
					aln.save!
				end
			end

		end

	end

end