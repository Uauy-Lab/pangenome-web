require_relative "../LoadFunctions.rb"
require 'bio'
require 'bio-samtools'
require 'bioruby-polyploid-tools'
require 'csv'  

def load_blat_alignments (blat_filename, marker_set,assembly, min_cov=80, min_identity = 95)
  #blat_aln = Bio::FlatFile.open(Bio::Blat, blat_file)
  puts blat_filename
  # io = 
  #blat_aln = Bio::Blat::Report.new(IO.read(blat_filename))
  blat_aln = Bio::Blat::Report.new(Bio::FlatFile.open(blat_filename).to_io)
  #p blat_aln
  count=0

  blat_aln.each_hit() do |hit|
    next if hit.query.size == 0
    current_matches = hit.match 
    current_identity = hit.percent_identity
#    puts "#{current_identity}, #{hit.percentage_covered}"
    next if current_identity < min_identity 
    next if hit.percentage_covered < min_cov
    next if hit.block_count > 1
    count += 1
 #   puts "PASS "
 #   puts hit.inspect
    current_score = hit.score

    current_name = LoadFunctions.iwgsc_canonical_contig(hit.target_id)
 #   p current_name
 #   p hit.query_id

   
    
    scaffold_db = Scaffold.find_or_create_by(
      name: current_name, 
      assembly: assembly, 
      length: hit.target_len)
    
    marker = LoadFunctions.find_marker_in_set(hit.query_id, marker_set)
    scaffoldMarker = ScaffoldsMarker.new
    #scaffoldMarker.assembly = assembly
    scaffoldMarker.scaffold = scaffold_db
    scaffoldMarker.marker_start = hit.query.start
    scaffoldMarker.marker_end  = hit.query.end
    scaffoldMarker.marker_orientation = hit.strand

    scaffoldMarker.scaffold_start = hit.target.start
    scaffoldMarker.scaffold_end  = hit.target.end
    scaffoldMarker.scaffold_orientation = "+"
    scaffoldMarker.identity = current_identity
    scaffoldMarker.marker = marker
    puts "Done: #{count}" if count % 1000 == 0

    scaffoldMarker.save
  end
   
end

namespace :marker do
  desc "Load marker alignments from blat"
  task :load_blat_position ,[:filename,:assembly,:marker_set,:species]  => :environment do |t, args|
   puts "Args were: #{args}"
      species_str = "Hexaploid wheat"
      species_str = args[:species] if args[:species]
      species = LoadFunctions.find_species(species_str)
      assembly = Assembly.find_or_create_by(name: args[:assembly])
      marker_set = MarkerSet.find_or_create_by(name: args[:marker_alias_detail])
   	  puts Rails.env
   	  load_blat_alignments(args[:filename], marker_set, assembly)
  end

  task :load_marker_from_820k_csv ,[:marker_set,:filename] => :environment do |t, args|
      @species = LoadFunctions.find_species("Hexaploid wheat")
      
      marker_set = MarkerSet.find_or_create_by(name: args[:marker_set])
      count = 0
      headers = Hash.new
      CSV.foreach(args[:filename], :headers => true) do |row|
      # use row here...
        marker = Marker.new
        marker.sequence = row["Sequence"]
        marker.name = row["Bristol_Affy_Code"]
        marker.marker_set = marker_set
        row.each do |header, value|  
          next if value == nil
          next if header == "Sequence"
          next if value.start_with? "No"
          marker.name = value unless marker.name
          
          #puts "#{header} => #{value}"
          mn = MarkerName.new 
          mn.alias = value
          mn.marker = marker
          detail = headers[header]
          unless detail
            detail = MarkerAliasDetail.find_or_create_by(alias_detail: header)
            headers[header] = detail
          end
          #puts detail.inspect
          mn.marker_alias_detail = detail
          marker.marker_names << mn 
          #puts mn.inspect
          count += 1
         
        end
        
        #puts marker.inspect
        #marker.save unless marker.name
        marker_set.markers << marker
      end
      puts "Done: #{count}" if count % 1000 == 0
      marker_set.save
  end

end
