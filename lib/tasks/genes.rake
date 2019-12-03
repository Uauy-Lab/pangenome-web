require_relative "../LoadFunctions.rb"
require 'bio'
require 'csv'  

namespace :genes do
  desc "Load the genes, from the ENSEMBL fasta file."
  task :ensembl_genes, [:gene_set, :filename] => :environment do |t, args|
    puts "Loading genes"
    ActiveRecord::Base.transaction do
      gene_set = GeneSet.find_or_create_by(:name=>args[:gene_set])
      Bio::FlatFile.open(Bio::FastaFormat, args[:filename]) do |ff|
        ff.each do |entry|
          arr = entry.definition.split( / description:"(.*?)" *| / )
          g = Gene.new 
          g.gene_set = gene_set
          g.name = arr.shift
          arr.each { |e| g.add_field(e) }
          g.save!
        end
      end
    end
  end

  desc "Load genes from a gff file"
  task :load_gff_gz, [:filename,:asm] => :environment do |t, args|
    puts "Loading gff"
    Zlib::GzipReader.open(args[:filename]) do |stream|
      LoadFunctions.load_features_from_gff(stream,assembly:args[:asm])
    end
  end
end