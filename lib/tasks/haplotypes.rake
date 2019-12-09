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
				next unless row["ref_assembly"]
				next if row["block_start"] == "NA"
				

				LoadFunctions.new_haplotype_block(row, hap_set, assembly_col: "subject")
				LoadFunctions.new_haplotype_block(row, hap_set, assembly_col: "target")
				
				#break
			end
			#throw Exception.new "Testing! Rollback"
		end
	end
end