require 'csv'
require_relative '../lib/LoadFunctions.rb'

contigs = Hash.new
$stderr.puts "Loading designed"
CSV.foreach("/Users/ramirezr/Dropbox/jic/Tilling/KASP/primers_Krons_for_martin_cov6.tsv", headers:true, col_sep:"\t") do |row|  
	scaff = row["Scaffold"]
	id = [row["WT"], row["Position"], row["ALT"]].join("")
	contigs[scaff] = Hash.new(false) unless contigs[scaff]
	contigs[scaff][id] = true
end

$stderr.puts "Loaded SNPs for #{contigs.size} contigs"

File.open("/Volumes/ramirezrVMs/forRicardo/combined.mapspart2.HetMinCov5HetMinPer15HomMinCov3.corrected.tsv") do |stream|
	count = 0
	csv = CSV.new(stream, :headers => false, :col_sep => "\t")
	snpsIds = nil
	current_chr = nil
	csv.each do |row|
		count += 1
		next if count == 1
		#puts row.inspect
		chr, pos,ref, totcov, wt, ma, lib, hohe, wtcov, macov, type, lcov, libs, ins_type,  mm_field = row.to_a
		snp_str = [wt,pos,ma].join("")
		#puts snpsIds

		next if contigs[chr] and contigs[chr][snp_str] 
		chr_pm=chr.split("_")[2][0,2]
		puts [chr,lib,pos,wt,ma].join(",")
	end
end
