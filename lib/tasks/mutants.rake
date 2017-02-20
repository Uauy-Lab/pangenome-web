require_relative "../LoadFunctions.rb"
require 'bio'
require 'csv'  

namespace :mutants do
	desc "Load the table of mutations. The expected headers are: Scaffold        chromosome      Library Line    position        chromosome position     ref_base        wt_base alt_base        het/hom wt_cov  mut_cov confidence      Gene    Feature Consequence     cDNA_position   CDS_position    Amino_acids     Codons  SIFT score"
	task :load_from_tsv, [:gene_set, :filename] => :environment do |t, args|
		ActiveRecord::Base.transaction do
			gene_set = GeneSet.find_or_create_by(:name=>args[:gene_set])
			CSV.foreach(args[:filename], :headers => true, :col_sep => "\t") do |row|
				puts row.inspect
				m = Mutation.new
				puts row[0]
				puts row[1]
				m.scaffold = Scaffold.find_by(:name=>row[0])
				m.chromosome = Chromosome.find_by(:name => row[1])
			end
		end
	end

	desc 'Save the summary of mutations per line'
	task :line_summary,[:filename] => :environment do |t, args|
		out = File.open(args[:filename], "w")
		i = 0
		Line.all.each do |l|
			i += 1
			values = Hash.new(0)
			sql=%{SELECT
	`lines`.id as line_id,
	confidence as category,
	mutations.het_hom as het_hom,
	effect_types.name as consequence,
	CASE when effects.sift_score < 0.05 then TRUE
		ELSE FALSE  
	END  as sift_lt_005, 
	COUNT(*) as total
FROM snps
JOIN mutations on mutations.SNP_id = snps.id
JOIN libraries on mutations.library_id = libraries.id
JOIN `lines` on libraries.line_id  = `lines`.id
LEFT JOIN effects on effects.snp_id = snps.id
LEFT JOIN effect_types on effect_types.id = effects.effect_type_id
WHERE confidence='het5hom3' 
and `lines`.id = #{l.id}
GROUP by 
	`lines`.id,
	mutations.het_hom,
	confidence,
	effects.effect_type_id,
	CASE when effects.sift_score < 0.05 then TRUE
		ELSE FALSE  
	END  
;}
			rs = ActiveRecord::Base.connection.execute(sql)
			puts rs.size
			rs.each do |record|
				out.puts record.inspect
				consequence = record[3]
				consequence = 'NA' unless consequence 
				consequence = consequence.split("&")[0]
				total = record[5]
				values[consequence] += total
				values[consequence + "_sift005"] += total if record[4]
				values[record[2]] += total
				values["total"] += total
			end 
			#stop_gained	#splice_donor_variant	#splice_acceptor_variant	#missense_variant	#missense_variant_sift<0.05	#missense_variant_sift<0.01	#synonymous_variant	#downstream_gene_variant	#upstream_gene_variant	#5_prime_UTR_variant	#3_prime_UTR_variant	#initiator_codon_variant	#OthrVariants
			#out.puts l.name 
			#out.puts l.id
			out.puts values.inspect
			break if i > 3
		end

		out.close
	end
end