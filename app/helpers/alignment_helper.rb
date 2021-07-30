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
end

