require_relative "../LoadFunctions.rb"
require 'bio'
require 'csv'  

namespace :scaffolds do
  desc "Load scaffolds from a fai file, with the scaffold names as in ensambl (IWGSC_CSS_1AL_scaff_1000404)"
  task :load_fai, [:name,:species,:filename] => :environment do |t, args|
  	ActiveRecord::Base.transaction do
     conn = ActiveRecord::Base.connection
      File.open(args[:filename]) do |stream|
  species=args[:species]
        assembly=args[:name]
        LoadFunctions.insert_scaffolds_from_stream(stream, species,assembly, conn)
      end
    end
  end

  desc "Load the mapping between scaffolds"
  task :load_scaffold_mapping_gz, [:filename] => :environment do |t, args|
    Zlib::GzipReader.open(args[:filename]) do |stream|
      LoadFunctions.load_scaffold_mapping(stream)
    end
  end

  desc "Copy the scaffold coordinate as a chromosome"
  task :copy_scaffold_coordinate_to_chromosome, [:scaffold, :chromosome, :assembly] => :environment do |t, args|
      LoadFunctions.copy_scaffold_cooridnates_to_coordinate(args[:scaffold], args[:chromosome], args[:assembly])
  end

 
  desc "Load scaffolds from a fai.gz file, with the scaffold names as in ensambl (IWGSC_CSS_1AL_scaff_1000404)"
  task :load_iwgsc_fai_from_zip, [:name,:species,:filename] => :environment do |t, args|
    ActiveRecord::Base.transaction do
      conn = ActiveRecord::Base.connection
      Zlib::GzipReader.open(args[:filename]) do |stream|
        species=args[:species]
        assembly=args[:name]
        LoadFunctions.insert_scaffolds_from_stream(stream, species,assembly, conn)
      end
    end
  end

  desc "Load the chromosome names for a species"
  task :load_chromosomes, [:species,:filename] => :environment do |t, args|
    ActiveRecord::Base.transaction do
      species = LoadFunctions.find_species(args[:species])
      CSV.foreach(args[:filename], :headers => false, :col_sep => "\t") do |row|
        LoadFunctions.find_chromosome(row[0],species)
      end
      species.save!
    end
  end
  
end
