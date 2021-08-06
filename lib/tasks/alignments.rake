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
	task :convert_window_coordinates,[:prefix,:round] => :environment do |t, args| 
		chr = "chr1A__chi"
		start = 500_000
		last  = 600_000

		chr = "chr2B__chi"
		start = 10_800_000
		last  = 10_900_000


		chr = "chr2B__chi"
		start = 10_000_000
		last  = 11_000_000


		# chr = "chr2B__chi"
		# start = 101_500_000
		# last  = 102_500_000

		species = "Wheat"
		round = args[:round].to_i
		flank = (start - last)/2
		flank = 50000
		sp = Species.find_species(species)

		to_print = AlignmentHelper.alignmnents_for_region(chr, start, last, round:round, flank: flank)

		to_print.each do |line|
			puts line.join("\t")
		end
		#asms = sp.assemblies

		# alns = Alignment.in_region_by_assembly(chr, start, last)
		
		# alns.each_pair do |k, v|
		# 	puts "----"
		# 	puts k
		# 	v.each do |aln|
		# 		puts "#{aln.region.to_s} : #{aln.corresponding.region.to_s}"
		# 	end
		# 	puts "==="
		# 	v = AlignmentHelper.round(v, round)
		# 	# v.each do |aln|
		# 	# 	puts "#{aln[0].to_s} : #{aln[1].to_s}"
		# 	# end
		# 	v = AlignmentHelper.canonical_orientation(v)
		# 	# puts "&&&"
		# 	# v.each do |aln|
		# 	# 	puts "#{aln[0].to_s} : #{aln[1].to_s}"
		# 	# end

		# 	# puts "..."
		# 	v = AlignmentHelper.merge_reciprocal(v)
		# 	# v.each do |aln|
		# 	# 	puts "#{aln[0].to_s} : #{aln[1].to_s}"
		# 	# end
		# 	# puts "***"
		# 	v = AlignmentHelper.merge(v, flank: flank)
		# 	# puts "````"
		# 	# v.each do |aln|
		# 	# 	puts "#{aln[0].to_s} : #{aln[1].to_s}"
		# 	# end
		# 	v = AlignmentHelper.crop(v, chr, start, last)
		# 	puts "~~~"
		# 	v.each do |aln|
		# 		puts "#{aln[0].to_s} : #{aln[1].to_s}"
		# 	end


		#end



		#alns = Alignment.in_region(chr, start, last)

		# alns.sort.each do |aln|
		# 	puts "-----"
		# 	puts aln
		# 	corresponding = aln.corresponding
		# 	puts corresponding
		# end
	end
end
