require 'csv'
require 'zlib'
filename = "/Volumes/ExtremeSSD/haplotypes/nucmer/all_20_kb_filtered_delta_tables.csv.gz"

def swap_region(reg)
	tmp = reg[1]
	reg[1] = reg[2]
	reg[2] = tmp
	reg
end

def is_reverse(reg)
	reg[2] < reg[1]
end

def reg_len(reg)
	(reg[2]-reg[1]).abs
end

Zlib::GzipReader.open(filename) do |stream|
	csv = CSV.new(stream, headers: true)
	last_row = nil
	csv.each do |row|
		#Columns: "rs","re","qs","qe","error","qid","rid","strand","r_length","perc_id","perc_id_factor","r_mid","q_mid","comparison","chrom"
		next unless row['rid'].start_with? "chr"
		next unless row['qid'].start_with? "chr"
		ref   = [row['rid'], row["rs"].to_f.to_i, row["re"].to_f.to_i]
		query = [row['qid'], row["qs"].to_f.to_i, row["qe"].to_f.to_i]
		len_ref = reg_len(ref).to_f
		len_que = reg_len(query).to_f
		p1 = len_ref / len_que
	
		unless p1.between?(0.9, 1.1)
			raise "#{row} have alignments with more than 10\% difference of length (#{len_ref} #{len_que} #{p1})"
		end

		if is_reverse(ref)
			#First occurance: chr2A__chi      75054369        75089644        chr2A__jul      78899373        78934589
			ref = swap_region(ref)
			query = swap_region(query)
		end
		puts "#{ref.join("\t")}\t#{query.join("\t")}"
		if is_reverse(query)
			ref = swap_region(ref)
			query = swap_region(query)
		end
		puts "#{query.join("\t")}\t#{ref.join("\t")}"
	end
end

#For downstream analysis, sort the file with this:
#bedtools sort -i all_20_kb_filtered_delta_tables.bed -g chromosomes.txt > all_20_kb_filtered_delta_tables.sorted.bed