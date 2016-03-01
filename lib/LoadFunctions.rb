class LoadFunctions




  def self.find_marker(name)
    marker = Marker.find_by_name(name)
    unless marker
      marker = Marker.new
      marker.name = name
      marker.save!
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
      detail.save!
      marker.marker_names << mn 
    else
      marker = marker[0]
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

  def self.find_assembly(name)
    begin
      assembly = Assembly.find_or_create_by(name: name)
    rescue ActiveRecord::RecordNotUnique
      retry
    end
    return assembly
  end


  def self.find_chromosome(name, species)
    @@chromosomes = Hash.new unless  defined? @@chromosomes
    full_name="#{species.name}.#{name}"
    return  @@chromosomes[full_name] if  @@chromosomes[full_name]
    puts "Loading chr #{full_name}"
    chromosome = Chromosome.find_by(name: name, species: species)
    unless chromosome
      chromosome = Chromosome.new
      chromosome.name = name
      chromosome.species = species
      chromosome.save!
    end
    return  @@chromosomes[full_name]  = chromosome
    return chromosome
  end

  def self.iwgsc_canonical_contig(name)
  	#IWGSC_CSS_1AL_scaff_110
  	arr=name.split("_")
  	return name if arr.size == 5
  	return "IWGSC_CSS_#{arr[0]}_scaff_#{arr[1]}" if arr.size == 2
  	raise Exception "Invalid name for IWGSC. It can be either like IWGSC_CSS_1AL_scaff_110 or 1AL_110"

  end


  def self.insert_scaffolds_from_stream(stream,species, assembly, conn)
    species = find_species(species)
    assembly = find_assembly(assembly)
    puts "Assembly: #{assembly}"
    count=0
    generated_str = ""
    inserts = Array.new
    csv = CSV.new(stream, :headers => false, :col_sep => "\t")
    csv.each do |row|
      inserts.push  prepare_insert_scaffold_sql(row[0], row[1], species, assembly)
      count += 1
      if count % 10000 == 0
        puts "Loaded #{count} scaffolds" 
        insert_scaffold_sql(inserts, conn)
      end
    end
    puts "Loaded #{count} scaffolds" 
    insert_scaffold_sql(inserts, conn)
  end

  def self.prepare_insert_scaffold_sql(contig, length, species, assembly)
        chr=contig.split("_")[2][0,2]
        chromosome = find_chromosome(chr,species)
        str="('#{contig}',#{length},#{chromosome.id},#{assembly.id},NOW(),NOW())"
        return str
  end

  def self.insert_scaffold_sql(inserts, conn)
    sql = "INSERT INTO scaffolds (`name`,`length`, `chromosome`, `assembly_id`,`created_at`, `updated_at`) VALUES #{inserts.join(", ")}"
    conn.execute sql
    inserts.clear
  end


end

