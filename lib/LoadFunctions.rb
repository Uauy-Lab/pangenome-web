class LoadFunctions
  def self.find_marker(name)
    marker = Marker.find_by_name(name)
    unless marker
      marker = Marker.new
      marker.name = name
    end
    return marker
  end

  def self.find_marker_in_set(name, marker_set)
    marker=Marker.where(marker_set: marker_set).joins(:marker_names).where(marker_names:{alias:name})
    if marker.size == 0 then 
      marker = Marker.new
      marker.name = name
      marker.marker_set = marker_set
      mn = MarkerName.new 
      mn.alias = name
      mn.marker = marker
      detail = MarkerAliasDetail.find_or_create_by(alias_detail: "default")
      mn.marker_alias_detail = detail
      marker.marker_names << mn 
    end
    return marker
  end

  def self.find_species(name)
    begin
      species = Species.find_or_create_by(name: name)
    rescue ActiveRecord::RecordNotUnique
      retry
    end
    return species
  end


  def self.find_chromosome(name, species)
    @chromosomes = Hash.new unless @chromosomes
    return  @chromosomes[name] if  @chromosomes[name]
    chromosome = Chromosome.find_by(name: name, species: species)
    unless chromosome
      chromosome = Chromosome.new
      chromosome.name = name
      chromosome.species = @species
    end
    return  @chromosomes[name]  = chromosome
    return chromosome
  end

  def self.iwgsc_canonical_contig(name)
  	#IWGSC_CSS_1AL_scaff_110
  	arr=name.split("_")
  	return name if arr.size == 5
  	return "IWGSC_CSS_#{arr[0]}_scaff_#{arr[0]}" if arr.size == 2
  	raise Exception "Invalid name for IWGSC. It can be either like IWGSC_CSS_1AL_scaff_110 or 1AL_110"

  end
end

