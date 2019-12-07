require_relative "../LoadFunctions.rb"
require 'bio'
require 'csv'  
require 'bio-pangenome'

namespace :haplotypes do 
	desc "Load precalculated haplotype blocks"
	task :load_blocks, [:filename, :analysis_id, :description] => :environment do |t,args|
		puts "Loading blocks"
		ActiveRecord::Base.transaction do
			feat_type = LoadFunctions.get_feature_type("haplotype_block")
			hap_set = HaplotypeSet.find_by(name:args[:analysis_id])
			throw Exception.new "#{args[:analysis_id]} already exists. Use a new name." unless hap_set.nil?
			feat_type = LoadFunctions.get_feature_type("haplotype_block")
			hap_set = HaplotypeSet.find_or_create_by(name:args[:analysis_id], description:args[:description])
			CSV.foreach(args[:filename], col_sep: "\t", headers:true) do |row|
				#puts row.inspect
				next unless row["assembly"]
				asm = LoadFunctions.find_assembly(row["assembly"])
				#puts asm.inspect

				scaff = Scaffold.find_by(name: row["chromosome"], assembly_id: asm)

				throw "Chromosome #{row["chromosome"]} not found in assembly #{row["assembly"]} #{row.inspect}" if scaff.nil?
				next if row["block_start"] == "NA"
				region =  Region.find_or_create_by(scaffold: scaff, 
					start: row["block_start"].to_i, end: row["block_end"].to_i 
					)

				genes = FeatureHelper.find_features_in_assembly(row["assembly"], "gene")

				hb =  HaplotypeBlock.new
				hb.block_no = row["block_no"]
				hb.region = region
				hb.assembly = asm
				hb.haplotype_set = hap_set
				feat_s = Feature.find(genes[row["start_transcript"]])
				feat_e = Feature.find(genes[row["end_transcript"]])
				hb.first_feature = feat_s
				hb.last_feature = feat_e
				#puts hb.inspect
				hb.save!
				#break
			end
			#throw Exception.new "Testing! Rollback"
		end
	end
end