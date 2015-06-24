require_relative "../LoadFunctions.rb"
namespace :genetic_map do

  def parse_genetic_map(str, marker_set, species)
    str.chomp!
    arr = str.split(/\s+/)
    positions = Array.new
    chrs = Hash.new 

    LoadFunctions.find_marker_in_set(arr[0], marker_set) do |m|  
      mapPos = MapPosition.new
      mapPos.marker = m
      mapPos.chromosome =  chrs[arr[1]] 
      unless mapPos.chromosome then
        chrs[arr[1]] = LoadFunctions.find_chromosome(arr[1], species)
        mapPos.chromosome = chrs[arr[1]] 
      end
      mapPos.centimorgan = arr[2].to_f
      mapPos.order = arr[3].to_i
      positions << mapPos
    end
    return positions
  end

	task :add ,[:name, :filename, :description, :marker_set , :species]  => :environment do |t, args|
  		puts "Args were: #{args}"
  		puts Rails.env
  		map = GeneticMap.new 
  		map.name = args[:name]
  		map.description = args[:description]
      species_str = "Hexaploid wheat"
      species_str = args[:species] if args[:species]
      species = LoadFunctions.find_species(species_str)
  		
      count = 0
      marker_set = MarkerSet.find_or_create_by(name: args[:marker_set])
      File.foreach(args[:filename]) do |line|  
  			#position = MapPosition.new
        #position.parse(line)
  			position = parse_genetic_map(line, marker_set, species)

        position.each { |pos|  map.map_positions << pos }
        count += 1
        puts "Done: #{count}" if count % 1000 == 0
  		end
      map.save
	end
end
