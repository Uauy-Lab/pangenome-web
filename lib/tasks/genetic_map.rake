namespace :genetic_map do

  def find_marker(name)
    marker = Marker.find_by_name(name)
    unless marker
      marker = Marker.new
      marker.name = name
    end
    return marker
  end

  def find_species(name)
    species = Species.find_by_name(name)
    unless species
      species = Species.new
      species.name = name
    end
    puts "Species"
    p species
    return species
  end


  def find_chromosome(name)
    @chromosomes = Hash.new unless @chromosomes
    return  @chromosomes[name] if  @chromosomes[name]

    chromosome = Chromosome.find_by_name(name)
    unless chromosome
      chromosome = Chromosome.new
      chromosome.name = name
      chromosome.species = @species
    end
    return  @chromosomes[name]  = chromosome
    return chromosome
  end

  def parse_genetic_map(str)
    str.chomp!
    arr = str.split(/\s+/)
    mapPos = MapPosition.new
    mapPos.marker = find_marker(arr[0])
    mapPos.chromosome = find_chromosome(arr[1])
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
      @species = find_species(@species_str)
  		File.foreach(args[:filename]) do |line|  
  			#position = MapPosition.new
        #position.parse(line)
  			position = parse_genetic_map(line)
        map.map_positions << position
  		end
      map.save
	end
end
