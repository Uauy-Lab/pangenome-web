require_relative "../LoadFunctions.rb"
namespace :genetic_map do

  def parse_genetic_map(str)
    str.chomp!
    arr = str.split(/\s+/)
    mapPos = MapPosition.new
    mapPos.marker = LoadFunctions.find_marker(arr[0])
    mapPos.chromosome = LoadFunctions.find_chromosome(arr[1])
    mapPos.centimorgan = arr[2].to_f
    mapPos.order = arr[3].to_i
    return mapPos
  end

	task :add ,[:name, :filename, :description, :species]  => :environment do |t, args|
  		puts "Args were: #{args}"
  		puts Rails.env
  		map = GeneticMap.new 
  		map.name = args[:name]
  		map.description = args[:description]
      @species_str = "Hexaploid wheat"
      @species_str = args[:species] if args[:species]
      @species = LoadFunctions.find_species(@species_str)
  		File.foreach(args[:filename]) do |line|  
  			#position = MapPosition.new
        #position.parse(line)
  			position = parse_genetic_map(line)
        map.map_positions << position
  		end
      map.save
	end
end
