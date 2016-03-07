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

  def self.get_scaffolds_hash
    scaffolds = Hash.new
    Scaffold.find_each(batch_size: 5000) do |scaff|
      scaffolds[scaff.name] = scaff.id
    end
    return scaffolds
  end
  
  def self.insert_snp_sql(inserts, conn)
      sql = "INSERT IGNORE INTO snps (`scaffold_id`, `position`, `ref`, `wt`,`alt`,`created_at`, `updated_at`)  VALUES #{inserts.join(", ")} "
      conn.execute sql
      inserts.clear
    end

  def self.insert_snps(stream)
    conn = ActiveRecord::Base.connection
    csv = CSV.new(stream, :headers => false, :col_sep => "\t")
    scaff = Scaffold.new
    inserts = Array.new
    count = 0
    csv.each do |row|
      count += 1
      contig = row[0]
      scaff = Scaffold.find_by_name(contig) unless contig == scaff.name
      pos = row[1] 
      ref = row[2]
      wt = row[4]
      alt = row[5]
      str = "('#{scaff.id}', #{pos}, '#{ref}', '#{wt}', '#{alt}', NOW(), NOW())"
      inserts << str
      if count % 10000 == 0
        puts "Loaded #{count} SNPs (#{contig})" 
        insert_snp_sql(inserts, conn)
      end
    end
    puts "Loaded #{count} SNPs" 
    insert_snp_sql(inserts, conn)
    count
  end

  def self.get_snp_hash_for_contig(contig)
    #sql="SELECT snps.id, scaffolds.name,  CONCAT(snps.wt, snps.position,  snps.alt  )
    # as snp FROM  snps INNER JOIN Scaffolds where scaffolds.name = '#{contig}'";
    snps = Hash.new

    Snp.joins(:scaffold).where("scaffolds.name = ? ", contig).each do |snp|
      str = [snp.wt, snp.position, snp.alt].join("")
      snps[str] = snp.id
    end
    snps
  end

  def insert_muts_sql(inserts, conn)

  end

  def self.insert_mutations(stream)
    conn = ActiveRecord::Base.connection
    csv = CSV.new(stream, :headers => false, :col_sep => "\t")
    scaff = Scaffold.new
    inserts = Array.new
    count = 0  
    current_chr = nil
    snpsIds = nil
    libs = Hash.new
    csv.each do |row|
      count += 1
      chr, pos,ref, totcov, wt, ma, lib, hohe, wtcov, macov, type, lcov = row.to_a
      if current_chr != chr
        current_chr = chr
        snpsIds = get_snp_hash_for_contig(chr)    
      end
      str = "()"
      inserts << str
      if inserts.size % 10000 == 0
        puts "Loaded #{inserts.size} mutations (#{chr})" 
        insert_muts_sql(inserts, conn)
      end
    end
    puts "Loaded #{inserts.size} mutations" 
    insert_muts_sql(inserts, conn)
  end

  def self.load_mutant_libraries(stream)
    csv = CSV.new(stream, :headers => true, :col_sep => "\t")
    csv.each do |row |
      #MutantName  library line  species Type
       species = Species.find_or_create_by(name: row["species"])
       current_line = Line.find_or_create_by(name: row["MutantName"])
       wt = Line.find_or_create_by(name: row["line"])
       wt.species = species
       wt.wildtype =  wt
       lib = Library.new
       lib.name = row["library"]
       lib.line = current_line
       lib.save!       
    end
  end

  def self.find_library(name)
    arr = name.split("_")
    ret = nil
    arr.each do |e|  
      ret = Library.find_by_name(e)
      return ret if ret
    end
    raise "#{name} not found!"
    ret = Library.find_or_create_by(name: arr[0])
    ret
  end

#"","chr","cm","Scaffold","Library",
#{}"AllAvg","AllSD","delsPerScaffold","delsPerLibrary"
  def self.load_deleted_scaffolds(stream)
    csv = CSV.new(stream, :headers => true, :col_sep => ",")
    csv.each do |row|
      lib = find_library(row["Library"])
      scaff = Scaffold.find_by_name(row["Scaffold"])
      del = DeletedScaffold.new
      del.scaffold = scaff
      del.library = lib
      del.cov_avg = row["AllAvg"]
      del.cov_sd = row["AllSD"]
      del.save!
    end
  end

end

