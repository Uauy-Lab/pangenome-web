require_relative "../LoadFunctions.rb"
require 'bio'
require 'bio-samtools'
require 'csv'  

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

  task :load_marker_from_820k_csv ,[:marker_set,:filename] => :environment do |t, args|
      @species = LoadFunctions.find_species("Hexaploid wheat")
      
      marker_set = MarkerSet.find_or_create_by(name: args[:marker_set])
      CSV.foreach(args[:filename], :headers => true) do |row|
      # use row here...
        marker = Marker.new
        marker.sequence = row["Sequence"]
        marker.name = row["Bristol_Affy_Code"]
        marker.marker_set = marker_set
        row.each do |header, value|  
          next if header == "Sequence"
          next if value.start_with? "No"
          marker.name = value unless marker.name
          
          puts "#{header} => #{value}"
          mn = MarkerName.new 
          mn.alias = value
          mn.marker = marker
          detail = MarkerAliasDetail.find_or_create_by(alias_detail: header)
          #puts detail.inspect
          mn.marker_alias_detail = detail
          marker.marker_names << mn 
          #puts mn.inspect
        end
        puts marker.inspect
        marker.save
      end
  end

end
