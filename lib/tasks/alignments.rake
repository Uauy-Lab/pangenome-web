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
		start = 500_000
		last  = 600_000

		chr = "chr2B__chi"
		start = 10_800_000
		last  = 10_900_000

		# chr = "chr2B__chi"
		# start = 101_500_000
		# last  = 102_500_000

		species = "Wheat"
		round = args[:round].to_i
		sp = Species.find_species(species)
		#asms = sp.assemblies

		alns = Alignment.in_region_by_assembly(chr, start, last, assemblies: [])
		
		alns.each_pair do |k, v|
			puts "----"
			puts k
			v = AlignmentHelper.round(v, round)
			v.each do |aln|
				puts "#{aln[0].to_s} : #{aln[1].to_s}"
			end
			puts "..."
			v = AlignmentHelper.merge_reciprocal(v)
			v.each do |aln|
				puts "#{aln[0].to_s} : #{aln[1].to_s}"
			end
			puts "***"
			v = AlignmentHelper.merge(v, flank: 100000)
			puts "````"
			v.each do |aln|
				puts "#{aln[0].to_s} : #{aln[1].to_s}"
			end


		end



		#alns = Alignment.in_region(chr, start, last)

		# alns.sort.each do |aln|
		# 	puts "-----"
		# 	puts aln
		# 	corresponding = aln.corresponding
		# 	puts corresponding
		# end
	end
end
