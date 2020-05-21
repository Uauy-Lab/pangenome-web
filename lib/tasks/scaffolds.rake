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

  desc "Sets the default assembly for a species"
  task :default_assembly, [:species, :assembly] => :environment do |t, args|
    ActiveRecord::Base.transaction do
      species = Species.find_by(name: args[:species])
      asms = species.assemblies
      c_asm = nil
      asms.each do |asm|
        c_asm = asm if asm.name == args[:assembly]
        asm.is_cannonical = false
        asm.save
      end
      throw "Assembly #{args[:assembly]} not found for #{args[:species]}" if c_asm.nil?
      c_asm.is_cannonical = true
      c_asm.save!
    end
  end

  desc "Updates the properties of each assembly.The assembly must exist in the species."
  task :update_assemblies, [:filename] => :environment do |t, args|
    ActiveRecord::Base.transaction do
      used_species = Hash.new
      CSV.foreach(args[:filename], col_sep: "\t", headers: true) do |row|
        throw "Column 'species' must not be empty" if row["species"].nil? or row["species"].length == 0
        puts row.inspect
        species = Species.find_by(name: row["species"])
        asm = species.assembly(row["assembly"])
        asm.is_cannonical = row["cannonical"].to_bool
        asm.is_pseudomolecule = row["pseudomolecule"].to_bool
        asm.description = row["description"] if row["description"]
        used_species[species.name] = species
        asm.save!
      end

      used_species.each_pair do |k,sp|
        cannonical_asms = []
        sp.assemblies.each do |asm|
          cannonical_asms << asm if asm.is_cannonical
        end
        throw "Setting the assembly preferences must keep a single cannonical assembly for #{sp.name} (#{cannonical_asms.map{|asm| asm.name}.join(",")})" if cannonical_asms.size != 1
      end

    end

  end
  
end
