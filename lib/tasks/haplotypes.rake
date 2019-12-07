require_relative "../LoadFunctions.rb"
require 'bio'
require 'csv'  
require 'bio-pangenome'

namespace :haplotypes do 
	desc "Load precalculated haplotype blocks"
	task :load_blocks, [:filename, :analysis_id, :description] => :environment do |t,args|
		feat_type = LoadFunctions.get_feature_type("haplotype_block")
		
	end

end