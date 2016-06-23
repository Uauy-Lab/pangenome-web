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
				puts m.inspect

			end
		end
	end
end