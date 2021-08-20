#!/usr/bin/env rails runner
bedfile="/Volumes/ExtremeSSD/haplotypes/nucmer/all_20_kb_filtered_delta_tables.sorted.bed.gz"
bedfile="/Users/ramirezr/Dropbox/JIC/Haplotypes/20210818_nucmer2B/all_20_kb_filtered_delta_spelta_2B_tables.sorted.bed.gz"
round=3
flank=50000
prefix="/Users/ramirezr/Dropbox/JIC/Haplotypes/20210818_nucmer2B/spelta_2B_merged_in_windows"
window_size=100000
filename = "#{prefix}__ws-#{window_size}_round-#{round}_flank-#{flank}.tsv"
out = File.open(filename, "w")
out.puts ["assembly","reference","chromosome","start","end","block_no","orientation" ].join("\t")

def aln_pair_to_tsv(aln, out:$stdout, id:"-")
	asm = aln[1].scaffold.assembly.name
	ref_asm = aln[0].scaffold.assembly.name
	line = [ref_asm,asm, aln[0].name, aln[0].first, aln[0].last, id , "+"]
	out.puts line.join("\t")
	line = [ref_asm,asm, aln[1].name, aln[1].first, aln[1].last, id , aln[1].orientation]
	out.puts line.join("\t")
end

def aln_pair_to_bed(aln, out:$stdout, id:"-")
	out.puts "#{aln[0].tsv}\t#{aln[1].tsv}"
end

Zlib::GzipReader.open(bedfile) do |stream|
	AlignmentHelper.alignments_per_chromosome(stream) do |chrom_alns|
		
		#puts chrom_alns
		chrom_alns.each_pair do |asm, alns|
			i = 0
			v = AlignmentHelper.round(alns, round)
			v = AlignmentHelper.canonical_orientation(v)
			v = AlignmentHelper.merge_reciprocal(v)
			#v = AlignmentHelper.merge(v, flank: flank)

			AlignmentHelper.alignments_in_window(v, window_size: window_size) do |region, alns2|
				$stderr.puts "#{asm}:#{region.to_s}" if i % 1000 == 0
				#out.puts "##{region.to_s}"
				alns2 =  AlignmentHelper.merge(alns2, flank: flank)
				alns2 =  AlignmentHelper.crop(alns2, region.name, region.start, region.end)
				id="#{region.name}:#{region.start}-#{region.end}"

				alns2.each do | aln|
					#aln_pair_to_bed(aln, out:out)
					aln_pair_to_tsv(aln, out:out, id:id)
					i += 1
				end		
			end

				
		end
		#break
	end
end
out.close