require_relative "../LoadFunctions.rb"
require 'bio'
require 'csv'  

namespace :alignments do
	desc "Load alignments from the CSV converted from the delta files. "
	task :load_csv_gz, [:filename] => :environment do |t, args|
		ActiveRecord::Base.transaction do
			Zlib::GzipReader.open(args[:filename]) do |stream|
				AlignmentHelper.load(stream)
			end
		end
	end

	desc "Fixes the orientation of regions"
	task :fixRegions => :environment do |t, args|
		ActiveRecord::Base.transaction do
			i = 0
			Region.find_each(batch_size:10000) do |r|
				if r.start > r.end 
					tmp = r.end 
					r.end = r.start
					r.start = tmp
					r.save!
					i += 1
					puts "fixed #{i} regions (#{r})" if i % 1000 == 0 
				end
			end
			puts "fixed #{i}" if i % 1000 == 0 
		end
	end

	desc "Convert windows from a CSV file using the delta files"
	task :convert_bed_coordinates,[:input,:round] => :environment do |t, args| 
		chr = "chr1A__chi"
		start = 100_000
		last  = 300_000
		alns = Alignment.in_region(chr, start, last)
		alns.sort.each do |aln|
			puts "-----"
			puts aln
			corresponding = aln.corresponding
			puts corresponding
		end
	end
end
