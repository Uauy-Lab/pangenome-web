module AlignmentHelper

	@@alignment_sets = nil
	def self.find_alignmet_set(name)
		@@alignment_sets = Hash.new unless @@alignment_sets
		unless @@alignment_sets[name]
			@@alignment_sets[name] = AlignmentSet.find_or_create_by(name: name)
			@@alignment_sets[name].alignments_count = 0 if @@alignment_sets[name].alignments_count.nil?
		end
		return @@alignment_sets[name]
	end

	def self.save_alignment_sets()
		@@alignment_sets.each_pair do |k, v|
			v.save!
		end
	end

	def self.build_alignment( aln_set: nil, scaffold: "", start:1, last:10, pident: 50, length: 10, orientation: "+")
		#scaff  = Scaffold.find_by(name: scaffold)
		#throw "Unable to find #{scaff} " if scaff.nil?
		region =  Region.find_for_save(scaffold: scaffold, start: start, end: last )
		aln = Alignment.new
		aln.alignment_set = aln_set
		aln.region = region
		aln.assembly = scaff.assembly
		aln.pident = pident
		aln.length = length
		aln.align_id = aln_set.alignments_count
		aln.orientation = orientation
		aln.save!
		return aln
	end


	def self.load(stream)
		#Columns: "rs","re","qs","qe","error","qid","rid","strand","r_length","perc_id","perc_id_factor","r_mid","q_mid","comparison","chrom"
		i = 0
		csv = CSV.new(stream, headers: true)
		last_row = nil
		csv.each do |row|
			aln_set = AlignmentHelper.find_alignmet_set(row["comparison"])
			aln_set.alignments_count += 1
			#puts aln_set.inspect
			AlignmentHelper.build_alignment(aln_set: aln_set, 
				scaffold:row["rid"], start: row["rs"], last: row["re"],  
				pident: row["perc_id"], length: row["r_length"], orientation: "+")
			AlignmentHelper.build_alignment(aln_set: aln_set, 
				scaffold:row["qid"], start: row["qs"], last: row["qe"],  
				pident: row["perc_id"], length: row["r_length"], orientation: row["strand"])
			i += 1
			#break if i > 3
			if i % 10000 == 0
				puts "#{i}: #{row}"
			end
			last_row = row
		end
		puts "#{i}: #{last_row}"
		AlignmentHelper.save_alignment_sets
		#throw "testing"
		puts "About to commit"
	end

	def self.bed_pair_to_regions(row)
		r1 = Region.new
		r1.scaffold = Scaffold.cached_from_name(row[0])
		r1.start = row[1].to_i
		r1.end   = row[2].to_i
		r2 = Region.new
		r2.scaffold = Scaffold.cached_from_name(row[3])
		r2.start = row[4].to_i
		r2.end   = row[5].to_i
		return [r1, r2]
	end

	def self.alignments_in_window(alns, window_size:100000)
		return [] if alns.length == 0
		chrom = alns[0][0].scaffold
		buffer  = []

		buffer_region = Region.new
		buffer_region.scaffold = chrom


		steps = 1.step(to: chrom.length, by:(window_size/2))
		i = 0
		steps.each do |start|
			last = start + window_size - 1
			buffer_region.start = start
			buffer_region.end   = last
			while i < alns.length and alns[i][0].overlap(buffer_region)
				buffer << alns[i]
				i +=1
			end
			buffer = buffer.filter do |aln|
				aln[0].overlap(buffer_region)
			end

			ret = buffer.map do |aln|
				[aln[0].copy, aln[1].copy ]
			end

			yield buffer_region, ret
		end


	end

	def self.alignments_per_chromosome(stream)
		csv = CSV.new(stream, headers: false, col_sep: "\t")
		i = 0
		ret = Hash.new() { |h, k|  h[k]  = [] }
		last_aln = nil
		csv.each do |row|
			aln = AlignmentHelper.bed_pair_to_regions(row)
			if ret.size > 0 and aln[0].scaffold != last_aln[0].scaffold
				$stderr.puts "#{last_aln[0].scaffold.name} loaded"
				yield ret
				ret = Hash.new() { |h, k|  h[k]  = [] }
			end
			ret[aln[1].scaffold.assembly.name].append(aln)
			i += 1
			last_aln = aln
		end
		yield ret 
	end



	def self.alignmnents_for_region(chr, first, last, id: nil, round: 4, flank:10000)
		id = "#{chr}:#{first}-#{last}" if id.nil?
		#alns = Alignment.in_region_by_assembly(chr, first, last)
		alns = Alignment.in_region_by_assembly_eager(chr, first, last)
		ret = []
		alns.each_pair do |k, aln|
			v = AlignmentHelper.round(aln, round)
			v = AlignmentHelper.canonical_orientation(v)
			v = AlignmentHelper.merge_reciprocal(v)
			v = AlignmentHelper.merge(v, flank: flank)
			v = AlignmentHelper.crop(v, chr, first, last)
			v.each do |pair| 
				ret << [pair[0].scaffold.assembly.name, pair[0].scaffold.assembly.name, pair[0].name,  pair[0].start, pair[0].end, id, pair[0].orientation]
				ret << [pair[0].scaffold.assembly.name, pair[1].scaffold.assembly.name, pair[1].name,  pair[1].start, pair[1].end, id, pair[1].orientation]
			end
		end
		ret 

	end

	def self.merge(alns, flank:0)
		return [] if alns.length == 0
		regions = []
		current = nil
		alns.each do |aln| 
			if current.nil?
				current = [aln[0].clone, aln[1].clone]
				regions.append(current)
				next
			end

			if current[0].overlap(aln[0], flank: flank) and current[1].overlap(aln[1], flank: flank) and current[1].orientation == aln[1].orientation
				current[0] = current[0].merge(aln[0], flank:flank)
				current[1] = current[1].merge(aln[1], flank:flank)
			else
				current = [aln[0].clone, aln[1].clone]
				regions.append(current)
			end
		end
		return regions
	end

	def self.round(alns, ndigits)
		alns.map do |aln|
			#[aln.region.round(ndigits), aln.corresponding.region.round(ndigits)]
			[aln[0].round(ndigits), aln[1].round(ndigits)]
		end
	end

	def self.canonical_orientation(alns)
		alns.map do |aln|
			if aln[0].orientation == "-"
				aln[0].reverse!
				aln[1].reverse!
			end
			aln
		end
	end

	def self.merge_reciprocal(regions)
		ret = []
		first = nil
		regions.each do |region_pair|
			if first.nil?
				first = region_pair
			else
				second = region_pair
				if first[0].overlap(second[0]) and first[1].overlap(second[1])
					ret.append(first)
				end
				first = nil
			end

		end
		return ret
	end

	def self.crop(alns, scaffold, first, last)
		alns.map do |aln|
			delta_start, delta_end = aln[0].crop!(scaffold, first, last)
			aln[1].delta_crop!(delta_start, delta_end)
			[aln[0], aln[1] ]
	 	end
	end


end

