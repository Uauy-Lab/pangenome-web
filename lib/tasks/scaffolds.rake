require_relative "../LoadFunctions.rb"
require 'bio'
require 'bio-samtools'
require 'bioruby-polyploid-tools'
require 'csv'  

namespace :scaffolds do
  desc "Load scaffolds from a fai file, with the scaffold names as in ensambl (IWGSC_CSS_1AL_scaff_1000404)"
  task :load_iwgsc_fai, [:name,:species,:filename] => :environment do |t, args|
  	ActiveRecord::Base.transaction do
      conn = ActiveRecord::Base.connection
      File.open(args[:filename]) do |stream|
        species=args[:species]
        assembly=args[:name]
        LoadFunctions.insert_scaffolds_from_stream(stream, species,assembly, conn)
      end
    end
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
end