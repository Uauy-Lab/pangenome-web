require_relative "../LoadFunctions.rb"
require 'bio'
require 'bio-samtools'

def load_blat_alignments (blat_filename, min_cov=80, min_identity = 98)
  #blat_aln = Bio::FlatFile.open(Bio::Blat, blat_file)
  puts blat_filename
  # io = 
  #blat_aln = Bio::Blat::Report.new(IO.read(blat_filename))
  blat_aln = Bio::Blat::Report.new(Bio::FlatFile.open(blat_filename).to_io)
  #p blat_aln
  blat_aln.each_hit() do |hit|
    current_matches = hit.match 
    current_name = LoadFunctions.iwgsc_canonical_contig(hit.target_id)
    current_identity = hit.percent_identity
    current_score = hit.score
    p current_name

   
end

namespace :marker do
  desc "Load marker alignmetns from blat"
  task :load_blat_position ,[:assembly, :filename, :species]  => :environment do |t, args|
   puts "Args were: #{args}"
      @species_str = "Hexaploid wheat"
      @species_str = args[:species] if args[:species]
      @species = LoadFunctions.find_species(@species_str)
   	  puts Rails.env
   	  load_blat_alignments(args[:filename])
  end

end
