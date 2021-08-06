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
		scaff  = Scaffold.find_by(name: scaffold)
		throw "Unable to find #{scaff} " if scaff.nil?
		region =  Region.find_or_create_by(scaffold: scaff, start: start, end: last )
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
			r_aln = AlignmentHelper.build_alignment(aln_set: aln_set, 
				scaffold:row["rid"], start: row["rs"], last: row["re"],  
				pident: row["perc_id"], length: row["r_length"], orientation: "+")
			q_aln = AlignmentHelper.build_alignment(aln_set: aln_set, 
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

	def self.alignmnents_for_region(chr, first, last, id: nil, round: 4, flank:10000)
		id = "#{chr}:#{first}-#{last}" if id.nil?
		alns = Alignment.in_region_by_assembly(chr, first, last)
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

			if current[0].overlap(aln[0], flank: flank) and current[1].overlap(aln[1], flank: flank)
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
			[aln.region.round(ndigits), aln.corresponding.region.round(ndigits)]
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

