require 'bio-gff3'
#require 'bio-samtools'
require 'set'
module Bio::GFFbrowser::FastLineParser
  module_function :parse_line_fast
end

#monkeypatch... 
class String
  def numeric?
    Float(self) != nil rescue false
  end
end

class LoadFunctions


  def self.find_marker(name)
    marker = Marker.find_by(name: name)
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
    @@assemblies = Hash.new unless defined? @@assemblies
    return @@assemblies[name] if @@assemblies[name]
    begin
      @@assemblies[name] = Assembly.find_or_create_by(name: name)
    rescue ActiveRecord::RecordNotUnique
      retry
    end
    return @@assemblies[name]
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
    begin
      chr=contig.split("_")[2][0,2]
    rescue
      $stderr.puts "unable to parse! #{contig}"
      return nil
    end
    chromosome = find_chromosome(chr,species)
    str="('#{contig}',#{length},#{chromosome.id},#{assembly.id},NOW(),NOW())"
    return str
  end

  def self.insert_scaffold_sql(inserts, conn)
    adapter_type = conn.adapter_name.downcase.to_sym
    case adapter_type
    when :mysql2 
      sql = "INSERT IGNORE INTO scaffolds (`name`,`length`, `chromosome`, `assembly_id`,`created_at`, `updated_at`) VALUES #{inserts.compact.join(", ")}"
    
    when :mysql 
      sql = "INSERT IGNORE INTO scaffolds (`name`,`length`, `chromosome`, `assembly_id`,`created_at`, `updated_at`) VALUES #{inserts.compact.join(", ")}"
    when :sqlite
      sql = "INSERT IGNORE INTO scaffolds (`name`,`length`, `chromosome`, `assembly_id`,`created_at`, `updated_at`) VALUES #{inserts.compact.join(", ")}"
    when :postgresql
      sql = "INSERT INTO scaffolds (name, length, chromosome, assembly_id, created_at, updated_at) VALUES #{inserts.compact.join(", ")} ON CONFLICT DO NOTHING"
    else
      raise NotImplementedError, "Unknown adapter type '#{adapter_type}'"
    end
    conn.execute sql
    inserts.clear
  end

  def self.insert_snp_sql(inserts, conn)
    begin
      adapter_type = conn.adapter_name.downcase.to_sym
      case adapter_type
      when :mysql2 
        sql = "INSERT IGNORE INTO snps (`scaffold_id`, `position`, `ref`, `wt`,`alt`,`species_id`,`created_at`, `updated_at`)  VALUES #{inserts.join(", ")} "
      when :mysql 
        sql = "INSERT IGNORE INTO snps (`scaffold_id`, `position`, `ref`, `wt`,`alt`,`species_id`,`created_at`, `updated_at`)  VALUES #{inserts.join(", ")} "
      when :sqlite
        sql = "INSERT IGNORE INTO snps (`scaffold_id`, `position`, `ref`, `wt`,`alt`,`species_id`,`created_at`, `updated_at`)  VALUES #{inserts.join(", ")} "
      when :postgresql
        sql = "INSERT INTO snps (scaffold_id, position, ref, wt, alt, species_id, created_at, updated_at)  VALUES #{inserts.join(", ")} ON CONFLICT DO NOTHING"
      else
        raise NotImplementedError, "Unknown adapter type '#{adapter_type}'"
      end
      conn.execute sql
      inserts.clear
    rescue ActiveRecord::StatementInvalid => e  
      puts e.message  
      #puts e.backtrace.inspect  
      ActiveRecord::Base.clear_active_connections!
    end

  end



  def self.insert_snps(stream)
    last_not_found = nil
    csv = CSV.new(stream, :headers => false, :col_sep => "\t")
    scaff = Scaffold.new
    inserts = Array.new
    count = 0
    count_not_found = 0
    toRepeatNames = Set.new
    toRepeatInserts = Array.new

    ActiveRecord::Base.transaction do
      conn = ActiveRecord::Base.connection
      csv.each do |row|
        count += 1
        contig = row[0]
        scaff = Scaffold.find_by(name: contig) if  scaff == nil  or contig != scaff.name
        pos = row[1] 
        ref = row[2]
        wt = row[4]
        alt = row[5]

        lib = find_library(row[6])
        #puts lib.inspect
        species = lib.line.species.id
        unless scaff
          scaff = Scaffold.find_or_create_by(name: contig)
          scaff.save!
          #next if last_not_found == contig
          last_not_found = contig
          puts "Scaffold not found! #{contig}" 
          toRepeatNames << contig
          count_not_found += 1
          #next
        end
        str = "(#{scaff.id}, #{pos}, '#{ref}', '#{wt}', '#{alt}', #{species}, NOW(), NOW())"
        if toRepeatNames.include? contig
          toRepeatInserts << str
        else
          inserts << str
        end

        if inserts.size % 1000 == 0 and inserts.size > 0
          puts "Loaded #{count} SNPs (#{contig})" 
          insert_snp_sql(inserts, conn)
        end
      end
      puts "Loaded #{count} SNPs" 
      puts "Unable to load #{count_not_found} SNPs"
      insert_snp_sql(inserts, conn) if inserts.size > 0
    end
    ActiveRecord::Base.transaction do
      conn = ActiveRecord::Base.connection
      toRepeatInserts.each_slice(1000).each_with_index do |inserts, i| 
         insert_snp_sql(inserts, conn)
         puts "Chunk in second innserts #{i}" 
      end
      puts "#{toRepeatInserts.size} inserted on second transaction"
    end
    count
  end
  
  @@current_scaff = nil
  def self.get_snp_id(scaffold:"",position:0, species_id:"", alt:"N",  wt:"X")
    if @@current_scaff == nil or scaffold !=  @@current_scaff
      @@current_scaff = scaffold
      @@snps_in_scaff = get_snp_hash_for_contig(@@current_scaff)
    end
    str = [wt, position, alt, species_id].join("")
    @@snps_in_scaff[str]
  end

  def self.get_snp_hash_for_contig(contig)
    #sql="SELECT snps.id, scaffolds.name,  CONCAT(srnps.wt, snps.position,  snps.alt  )
    # as snp FROM  snps INNER JOIN Scaffolds where scaffolds.name = '#{contig}'";
    snps = Hash.new

    Snp.joins(:scaffold).where("scaffolds.name = ? ", contig).each do |snp|
      str = [snp.wt, snp.position, snp.alt,snp.species_id].join("")
      snps[str] = snp.id
    end
    snps
  end

  def self.insert_muts_sql(inserts, conn)
    adapter_type = conn.adapter_name.downcase.to_sym
    case adapter_type
    when :mysql 
      sql = "INSERT IGNORE INTO mutations (`het_hom`,`wt_cov`, `mut_cov`, `SNP_id`, `total_cov` ,`library_id`, `mm_count`,`hom_corrected`, `confidence`, `created_at`,`updated_at`) VALUES #{inserts.join(", ")}"
    when :mysql2 
      sql = "INSERT IGNORE INTO mutations (`het_hom`,`wt_cov`, `mut_cov`, `SNP_id`, `total_cov` ,`library_id`, `mm_count`,`hom_corrected`, `confidence`, `created_at`,`updated_at`) VALUES #{inserts.join(", ")}"
    when :sqlite
      sql = "INSERT IGNORE INTO mutations (`het_hom`,`wt_cov`, `mut_cov`, `SNP_id`, `total_cov` ,`library_id`, `mm_count`,`hom_corrected`, `confidence`, `created_at`,`updated_at`) VALUES #{inserts.join(", ")}"
    when :postgresql
      sql = "INSERT INTO mutations (het_hom, wt_cov, mut_cov, SNP_id, total_cov, library_id, mm_count, hom_corrected, confidence, created_at, updated_at) VALUES #{inserts.join(", ")} ON CONFLICT DO NOTHING"
    else
      raise NotImplementedError, "Unknown adapter type '#{adapter_type}'"
    end

   conn.execute sql
   inserts.clear
 end

def self.get_scaffold_mappings(chromosome)
  ret = Hash.new
  chr = Scaffold.find_by(name:chromosome)
  ScaffoldMapping.where(scaffold_id:chr).find_each(batch_size: 100000) do |mapping|
    ret[mapping.coordinate] = {scaffold_id: mapping.other_scaffold_id, coordinate: mapping.other_coordinate}
  end
  return ret
end

def self.get_scaffold_id(name, assembly:'') 
  return get_scaffold(name, assembly:assembly).id
end

 @@scaffolds = nil
 def self.get_scaffold(name, assembly:'') 
  @@scaffolds = Hash.new unless @@scaffolds
  local_name = "#{assembly}:#{name}"
  unless @@scaffolds[local_name]
    scaff = false
    
    if assembly.length > 0
      asm = find_assembly(assembly)
      scaff = Scaffold.find_or_create_by(name: name, assembly_id: asm.id)
    else
      scaff = Scaffold.find_or_create_by(name: name)
    end

    unless scaff
       puts "Unknown scaffold #{local_name}" 
       return nil
    end
    @@scaffolds[local_name] = scaff  
  end
  @@scaffolds[local_name] 
end

def self.parse_mm_field(text, snp_id)
    #puts text
    count  = text.match(/Highly repetitive, (\d+) alternate locations/)
    return count[1].to_i, [] if count
    arr = text.split(",")
    count = arr.size
    inserts = Array.new
    arr.each do |name| 
      scaff_id = get_scaffold_id(name)
      str = "(#{snp_id}, #{scaff_id}, NOW(), NOW())"
      inserts << str if scaff_id
    end
    return arr.size, inserts
  end

  def self.insert_mm_sql(inserts, conn)
    adapter_type = conn.adapter_name.downcase.to_sym
    case adapter_type
    when :mysql 
      sql = "INSERT IGNORE INTO multi_maps (`snp_id`,`scaffold_id`,`created_at`,`updated_at`) VALUES #{inserts.join(", ")}"
    when :mysql2 
      sql = "INSERT IGNORE INTO multi_maps (`snp_id`,`scaffold_id`,`created_at`,`updated_at`) VALUES #{inserts.join(", ")}"
    when :sqlite
      sql = "INSERT IGNORE INTO multi_maps (`snp_id`,`scaffold_id`,`created_at`,`updated_at`) VALUES #{inserts.join(", ")}"
    when :postgresql
      sql = "INSERT INTO multi_maps (snp_id, scaffold_id, created_at, updated_at) VALUES #{inserts.join(", ")}  ON CONFLICT DO NOTHING"
    else
      raise NotImplementedError, "Unknown adapter type '#{adapter_type}'"
    end

   # puts sql
   conn.execute sql
   inserts.clear
 end

 def self.insert_mutations(stream, hethomconf)
  conn = ActiveRecord::Base.connection
  csv = CSV.new(stream, :headers => false, :col_sep => "\t")
  scaff = Scaffold.new
  inserts = Array.new
  count = 0  
  current_chr = nil
  snpsIds = nil
  libs = Hash.new
  inserts_mm = Array.new
  count_mm = 0
  species = nil
  csv.each do |row|
    count += 1
    mm_count = 0
    chr, pos,ref, totcov, wt, ma, lib, hohe, wtcov, macov, type, lcov, libs, ins_type,  mm_field = row.to_a
    lib = find_library(lib)
    species = lib.line.species.id 
    
    snp_id = get_snp_id(scaffold: chr, position:pos, species_id:species, alt:ma, wt:wt)
    raise "SNP not found #{chr} #{row} scaffold: #{chr}, position:#{pos}, species_id:#{species}, alt:#{ma}, wt:#{wt}" unless snp_id

    hom_corrected ="F"
    if mm_field and mm_field.start_with? "Warning: corrected to hom"  
      hom_corrected="T"
    elsif mm_field 
      mm_count, mm_insert = parse_mm_field(mm_field, snp_id) 
      inserts_mm.concat mm_insert
    end
    
    str = "('#{hohe}',#{wtcov},#{macov},#{snp_id},#{totcov}, #{lib.id},#{mm_count},'#{hom_corrected}', '#{hethomconf}', NOW(),NOW())"
    inserts << str
    
    if inserts.size % 1000 == 0
      puts "Loaded #{count} mutations (#{chr})" if count %10000 == 0
      insert_muts_sql(inserts, conn)
    end
    if inserts_mm.size > 1000 
      count_mm += inserts_mm.size
      puts "Loaded #{count_mm} multimap (#{chr})"  if count_mm %10000 == 0
      insert_mm_sql(inserts_mm, conn)
    end
    str = ""
  end
  puts "Loaded #{count} mutations" 
  insert_muts_sql(inserts, conn) if inserts.size > 0
  count_mm += inserts_mm.size
  puts "Loaded #{count_mm} multimap" 
  insert_mm_sql(inserts_mm, conn) if inserts_mm.size > 0
end

def self.load_mutant_libraries(stream)
  csv = CSV.new(stream, :headers => true, :col_sep => "\t")
  ActiveRecord::Base.transaction do
    csv.each do |row |
        #MutantName  library line  species Type
        species = Species.find_or_create_by(name: row["species"])
        current_line = Line.find_or_create_by(name: row["MutantName"])
        current_line.species = species
        current_line.mutant ="Y"
        wt = Line.find_or_create_by(name: row["line"])
        wt.species = species
        wt.mutant = "N"
        current_line.wildtype = wt
        current_line.save!
        wt.save!
        #wt.wildtype =  wt
        lib = Library.new
        lib.name = row["library"]
        lib.line = current_line
        
        lib.save!       
      end
    end
  end

  def self.find_library(name, create:true)
    @libraries = Hash.new unless @libraries
    return @libraries[name] if @libraries[name]
    arr = name.split("_")
    ret = nil
    arr.each do |e|  
      ret = Library.find_by(name: e)
      @libraries[name] = ret
      return ret if ret
    end
    puts  "Library: #{name} not found!"
    ret = Library.find_or_create_by(name: arr[0])
    @libraries[name] = ret
    ret
  end


   def self.find_line(name)
    @lines = Hash.new unless @lines
    return @lines[name] if @lines[name]
    arr = name.split("_")
    ret = nil
    arr.each do |e|  
      ret = Line.find_by(name: e)
      @lines[name] = ret
      return ret if ret
    end
    puts  "Library: #{name} not found!"
    ret = Line.find_or_create_by(name: arr[0])
    @lines[name] = ret
    ret
  end

  #"","chr","cm","Scaffold","Library",
  #{}"AllAvg","AllSD","delsPerScaffold","delsPerLibrary"
  def self.load_deleted_scaffolds(stream)
    csv = CSV.new(stream, :headers => true, :col_sep => ",")
    ActiveRecord::Base.transaction do
      csv.each do |row|
       lib = find_library(row["Library"])
       scaff = Scaffold.find_by(name: row["Scaffold"])
       del = DeletedScaffold.new
       del.scaffold = scaff
       del.library = lib
       del.cov_avg = row["AllAvg"]
       del.cov_sd = row["AllSD"]
       del.save!
      end
    end
  end

  def self.load_deleted_exons(stream)
    csv = CSV.new(stream, :headers => true, :col_sep => ",")
    count = 0
    ActiveRecord::Base.transaction do
      csv.each do |row|
        next unless row["HomDel"] == "TRUE"
        scaff = Scaffold.find_by(name: row["Scaffold"])
        next unless scaff
        arr = row['Exon'].split(":")
        reg = Region.find_or_create_by(scaffold: scaff, start: arr[1].to_i, end: arr[2])
        lib = find_library(row["Library"])
        regCov = RegionCoverage.new
        regCov.library = lib
        regCov.region = reg
        regCov.coverage = row["NormCov"].to_f
        regCov.hom = row["HomDel"][0]
        regCov.het = row["HetDel1"][0]
        regCov.save!
        count += 1
        puts "Loaded #{count} exons #{row["Exon"]}, #{row["Library"]}" if count % 1000 == 0
      end
    end
    puts "DONE: Loaded #{count.to_s} exons"
  end

  @@biotypes = nil
  def self.get_biotype(name)
    @@biotypes = Hash.new unless @@biotypes
    @@biotypes[name] = Biotype.find_or_create_by(name: name) unless @@biotypes[name]
    @@biotypes[name]
  end

  @@feature_types = nil
  def self.get_feature_type(name)
    @@feature_types = Hash.new unless @@feature_types
    @@feature_types[name] = FeatureType.find_or_create_by(name:  name) unless @@feature_types[name]
    @@feature_types[name]
  end


  @@gene_sets = nil
  def self.get_gene_set(name)
    @@gene_sets = Hash.new unless @@gene_sets
    @@gene_sets[name] = GeneSet.find_or_create_by(name:  name) unless @@gene_sets[name]
    @@gene_sets[name]
  end

  def self.load_features_from_gff(stream)
    parser = Bio::GFFbrowser::FastLineParser
    scaff = Scaffold.new
    parents = Hash.new

    i = 0
    ActiveRecord::Base.transaction do
      stream.each_line do |line|
        line.strip!
        break if line == '##FASTA'
        parents.clear if line == '###'
        next if line.length == 0 or line =~ /^#/
        #puts line
        record = Bio::GFFbrowser::FastLineRecord.new(parser.parse_line_fast(line))
        asm = find_assembly(record.source)
        gs  = get_gene_set(record.source)
        scaff = Scaffold.find_or_create_by(name: record.seqid, assembly_id: asm) unless scaff.name == record.seqid
        next unless scaff
        name = record.id
        feature = Feature.new
        feature.region = Region.find_or_create_by(scaffold: scaff, start: record.start, end: record.end )
        feature.biotype = get_biotype record.get_attribute "biotype"  if record.get_attribute "biotype"
        feature.feature_type = get_feature_type record.feature
        feature.name = name
        feature.orientation = record.strand
        feature.frame = record.phase
        feature.parent = parents[record.get_attribute "Parent"] if record.get_attribute "Parent"
        parents[name] = feature
        feature.save
        #puts feature.inspect
        Gene.find_or_create_by(name: record.id, gene_set: gs, position: feature.parent.region.to_s, cdna:record.id) if record.feature == "mRNA"
        i += 1
        if i % 10000 == 0
          puts "Loaded #{i.to_s} features #{record.id} #{feature.region.to_s}"
        end
      end
    end
    puts "DONE: Loaded #{i.to_s} features"
  end

  @@effect_types = nil
  def self.get_effect_type(name)
    @@effect_types = Hash.new unless @@effect_types
    @@effect_types[name] = EffectType.find_or_create_by(name:  name) unless @@effect_types[name]
    @@effect_types[name]
  end

  def self.insert_effs_sql(inserts, conn)
    adapter_type = conn.adapter_name.downcase.to_sym
    case adapter_type
    when :mysql 
      sql = "INSERT IGNORE INTO effects (`snp_id`,`feature_id`, `effect_type_id`, `cdna_position`, `cds_position`, `protein_position`, `amino_acids`, `codons`, `sift_score`,`created_at`,`updated_at`) VALUES #{inserts.join(", ")}"
    when :mysql2
      sql = "INSERT IGNORE INTO effects (`snp_id`,`feature_id`, `effect_type_id`, `cdna_position`, `cds_position`, `protein_position`, `amino_acids`, `codons`, `sift_score`,`created_at`,`updated_at`) VALUES #{inserts.join(", ")}"
    when :sqlite
      sql = "INSERT IGNORE INTO effects (`snp_id`,`feature_id`, `effect_type_id`, `cdna_position`, `cds_position`, `protein_position`, `amino_acids`, `codons`, `sift_score`,`created_at`,`updated_at`) VALUES #{inserts.join(", ")}"
    when :postgresql
      sql = "INSERT INTO effects (snp_id, feature_id, effect_type_id, cdna_position, cds_position, protein_position, amino_acids, codons, sift_score, created_at, updated_at) VALUES #{inserts.join(", ")} ON CONFLICT DO NOTHING"
    else
      raise NotImplementedError, "Unknown adapter type '#{adapter_type}'"
    end

    conn.execute sql
    inserts.clear
  end
  

  def self.insert_scaffold_mapings_sql(inserts, conn)
    adapter_type = conn.adapter_name.downcase.to_sym
    case adapter_type
    when :mysql 
      sql = "INSERT IGNORE INTO scaffold_mappings(`scaffold_id`, `coordinate`, `other_scaffold_id`, `other_coordinate`,`created_at`, `updated_at`) VALUES #{inserts.join(", ")}"
    when :mysql2 
      sql = "INSERT IGNORE INTO scaffold_mappings(`scaffold_id`, `coordinate`, `other_scaffold_id`, `other_coordinate`,`created_at`, `updated_at`) VALUES #{inserts.join(", ")}"
    when :sqlite
      sql = "INSERT IGNORE INTO scaffold_mappings(`scaffold_id`, `coordinate`, `other_scaffold_id`, `other_coordinate`,`created_at`, `updated_at`) VALUES #{inserts.join(", ")}"
    when :postgresql
      sql = "INSERT INTO scaffold_mappings(scaffold_id, coordinate, other_scaffold_id, other_coordinate, created_at, updated_at) VALUES #{inserts.join(", ")} ON CONFLICT DO NOTHING"
    else
      raise NotImplementedError, "Unknown adapter type '#{adapter_type}'"
    end

    conn.execute sql
    inserts.clear
  end

  def self.load_scaffold_mapping(stream)
    puts "Lading mapping between scaffolds"
    count = 0
    inserts = Array.new
    ActiveRecord::Base::transaction do 
      conn = ActiveRecord::Base.connection
      current_scaff = ""
      current_chr = ""
      stream.each_line do |line|
        line.chomp!
        arr = line.split(",")
        scaffArr = arr[0].split(":")
        chrArr   = arr[1].split(":")
        posId    = chrArr[2] + ":" + chrArr[3]
        

        scaff = get_scaffold(scaffArr[2]) unless scaffArr[2] == current_scaff
        chr   = get_scaffold(  chrArr[2], assembly:chrArr[1])   unless chrArr[2] == current_chr

        inserts <<  "(" + [scaff.id, scaffArr[3].to_i, chr.id, chrArr[3].to_i, "NOW()", "NOW()"].join(", ") + ")"
        inserts <<  "(" + [chr.id, chrArr[3].to_i, scaff.id, scaffArr[3].to_i, "NOW()", "NOW()"].join(", ") + ")"

        count += 1
        if inserts.size > 10000
          puts "Loaded #{count} scaffolds" 
          insert_scaffold_mapings_sql(inserts, conn)
        end
      end
      if inserts.size > 1
        puts "Loaded #{count} scaffolds" 
        insert_scaffold_mapings_sql(inserts, conn)
      end
    end
  end

  def self.copy_scaffold_cooridnates_to_coordinate(original, target, assembly)
    puts "Copying coordinates from #{original} to #{target}"
    count = 0
    inserts = Array.new
    chr_id = get_scaffold_id(target, assembly:assembly)
    ActiveRecord::Base::transaction do 
      conn = ActiveRecord::Base.connection
      
      #puts chr.inspect
      #Snp.join(:scaffold).where("scaffolds.name=IWGSC_3BSEQ_3B_traes3bPseudomoleculeV1")
      Snp.joins(:scaffold).where("scaffolds.name='#{original}'").find_in_batches() do |batch|
        batch.each do |snp|
          count += 1
          inserts <<  "(" + [snp.scaffold_id, snp.position, chr_id, snp.position, "NOW()", "NOW()"].join(", ") + ")"
          inserts <<  "(" + [chr_id, snp.position, snp.scaffold_id, snp.position, "NOW()", "NOW()"].join(", ") + ")"
          if inserts.size > 10000
            puts "Loaded #{count} mappings" 
            insert_scaffold_mapings_sql(inserts, conn)
          end
        end
        puts "Loaded #{count} mappings" 
        insert_scaffold_mapings_sql(inserts, conn) if inserts.size > 1
      end

    end
  end


  def self.loadMappedSNPs(mappingFile, species)
    puts "loadMappedSNPs"
    species = Species.find_by(name: species)
    puts species.inspect
    mappingHash = Hash.new
    scaff = nil
    Zlib::GzipReader.open(mappingFile) do |stream|
      stream.each_line do |line|
        line.chomp!
        arr = line.split(",")
        scaffArr = arr[0].split(":")
        chrArr   = arr[1].split(":")
        posId    = chrArr[2] + ":" + chrArr[3]
        
        scaff = get_scaffold_id(scaffArr[2])

        snp = Snp.find_by(species_id: species, scaffold: scaff ,position: scaffArr[3])
        puts snp.inspect

      end
    end
  end

  def self.load_vep_effects_from_vcf_with_mapping(stream, species)
    puts "load_vep_effects_from_vcf_with_mapping (#{species})"
    species = Species.find_by(name: species)
    puts species.inspect
    i=0
    vep_headers = [
      :Allele,
      :Consequence,
      :IMPACT,
      :SYMBOL,
      :Gene,
      :Feature_type,
      :Feature,
      :BIOTYPE,
      :EXON,
      :INTRON,
      :HGVSc,
      :HGVSp,
      :cDNA_position,
      :CDS_position,
      :Protein_position,
      :Amino_acids,
      :Codons,
      :Existing_variation,
      :DISTANCE,
      :STRAND,
      :SYMBOL_SOURCE,
      :HGNC_ID,
      :SIFT
    ]
    #vep_headers = [:Allele, :Gene, :Feature, :Feature_type, :Consequence, :cDNA_position, :CDS_position, :Protein_position, :Amino_acids, :Codons, :Existing_variation, :DISTANCE, :STRAND]
    head_arr = vep_headers.each_with_index.map { |e, i| [e , i] }
    vidx =  Hash[head_arr.to_a]
    scaff = Scaffold.new
    features = Hash.new
    #VEP header: Allele|Consequence|IMPACT|SYMBOL|Gene|Feature_type|Feature|BIOTYPE|EXON|INTRON|HGVSc|HGVSp|cDNA_position|CDS_position|Protein_position|Amino_acids|Codons|Existing_variation|DISTANCE|STRAND|SYMBOL_SOURCE|HGNC_ID|SIFT
    current_chr = ""
    curr_scaff = ""
    inserts = Array.new
    snpsIds = Hash.new
    snpMapping = nil
    ActiveRecord::Base::transaction do 
      conn = ActiveRecord::Base.connection
      stream.each_line do | line |
        line.chomp!
        next if line.length == 0 or line =~ /^#/
        vcf = Bio::DB::Vcf.new(line)
        next unless vcf.info["CSQ"] || vcf.info["VE"]
        if current_chr != vcf.chrom and vcf.chrom.length < 10 #only load long mappings (not 3B)
          current_chr = vcf.chrom
          snpMapping = get_scaffold_mappings(current_chr)
        end
       map = nil
       map = snpMapping[vcf.pos] if current_chr == vcf.chrom
       snp_id = nil
       if map
        snp = Snp.find_by(scaffold_id:map[:scaffold_id], position:map[:coordinate], alt:vcf.alt, species_id:species.id)  
        puts "SNP not found for map: #{map.inspect} (#{line})" unless snp
        snp_id = snp.id
       else
        snp_id = get_snp_id(scaffold: vcf.chrom, position: vcf.pos, species_id: species.id, alt:vcf.alt, wt:vcf.ref)
       end

       raise  "SNP not found for \n#{line}\n#{vcf.inspect}" unless snp_id
        
        ve_arr = vcf.info["CSQ"].split(",")
        ve_arr = vcf.info["VE"].split(",") unless ve_arr
        ve_arr = [ve_arr] if ve_arr.instance_of? String
        #puts "#{ve_arr.inspect}"
        ve_arr.each do | ve |
          vep = ve.split("|")
          feat_id = "NULL"
          feat = vep[vidx[:Feature]]
          #puts vep.inspect
          features.clear if features.size > 10
          if feat and feat.size > 0
            begin 
              features[feat] = Feature.find_or_create_by(name: feat).id unless features[feat] 
              feat_id = features[feat] 
            rescue 
              File.open("MissingGenes.txt", "a") { |io| io.puts feat}
              $stderr.puts "Unable to find #{feat}"
            end
          end
          eff = get_effect_type(vep[vidx[:Consequence]])
          cds_pos  = "NULL"
          cdna_pos = "NULL"
          protein_pos = "NULL"
          aa = "NULL"
          cods = "NULL"
          sift = "NULL"
          cdna_pos =  vep[vidx[:cDNA_position]] if vep[vidx[:cDNA_position]] and  vep[vidx[:cDNA_position]].size > 1
          cds_pos  =  vep[vidx[:CDS_position]] if vep[vidx[:CDS_position]] and vep[vidx[:CDS_position]].size > 1
          protein_pos  =  vep[vidx[:Protein_position]] if vep[vidx[:Protein_position]] and vep[vidx[:Protein_position]].size > 1
          aa =   '\'' + vep[vidx[:Amino_acids]] + '\'' if vep[vidx[:Amino_acids]]  and vep[vidx[:Amino_acids]].size > 1
          cods = '\'' + vep[vidx[:Codons]]  + '\'' if vep[vidx[:Codons]]  and vep[vidx[:Codons]].size > 1
          sift = vep[vidx[:SIFT]].to_f if vep[vidx[:SIFT]]  and vep[vidx[:SIFT]].numeric?
          inFields =  [
            snp_id.to_s, 
            feat_id.to_s, 
            eff.id.to_s, 
            cdna_pos.to_s, 
            cds_pos.to_s, 
            protein_pos.to_s, 
            #'"' + aa  + '"',
            #'"' + cods + '"' ,
            aa.to_s,
            cods.to_s,
            sift.to_s,
            "NOW()", "NOW()" 
          ]
          str = "(#{inFields.join(",")})"
          inserts << str
        end
        i+= 1
        if inserts.size > 1000
          insert_effs_sql(inserts, conn)
          puts "Loaded #{i.to_s} effects #{current_chr}"
        end
      end
      insert_effs_sql(inserts, conn)
      puts "Loaded #{i.to_s} effects"
    end
  end

  ##Function below deprecated - doesn't use new protein_position in scehma
  def self.load_vep_effects_from_vcf(stream)
    i=0
    vep_headers = [:Allele, :Gene, :Feature, :Feature_type, :Consequence, :cDNA_position, :CDS_position, :Protein_position, :Amino_acids, :Codons, :Existing_variation, :DISTANCE, :STRAND]
    head_arr = vep_headers.each_with_index.map { |e, i| [e , i] }
    vidx =  Hash[head_arr.to_a]
    scaff = Scaffold.new
    features = Hash.new
    #VEP header: Allele|Gene|Feature|Feature_type|Consequence|cDNA_position|CDS_position|Protein_position|Amino_acids|Codons|Existing_variation|DISTANCE|STRAND
    #VEP header: Allele|Consequence|IMPACT|SYMBOL|Gene|Feature_type|Feature|BIOTYPE|EXON|INTRON|HGVSc|HGVSp|cDNA_position|CDS_position|Protein_position|Amino_acids|Codons|Existing_variation|DISTANCE|STRAND|SYMBOL_SOURCE|HGNC_ID|SIFT
    current_chr = ""
    inserts = Array.new
    snpsIds = Hash.new
    ActiveRecord::Base::transaction do 
      conn = ActiveRecord::Base.connection
      stream.each_line do | line |
        line.chomp!
        next if line.length == 0 or line =~ /^#/
        
        vcf = Bio::DB::Vcf.new(line)
        scaff = get_scaffold(vcf.chrom) unless scaff.name == vcf.chrom
        if current_chr != vcf.chrom
          current_chr = vcf.chrom
          snpsIds = get_snp_hash_for_contig(current_chr)
        end

        snp_str = [vcf.ref,vcf.pos,vcf.alt].join("")
        snp_id = snpsIds[snp_str]
        next unless vcf.info["VE"]
        ve_arr = vcf.info["VE"]
        ve_arr.each do | ve |
          vep = ve.split("|")
          feat_id = "NULL"
          feat = vep[vidx[:Feature]]
          features.clear if features.size > 10
          if feat.size > 0
            begin 
              features[feat] = Feature.find_by(name: feat).id unless features[feat] 
              feat_id = features[feat] 
            rescue 
              raise "Unable to find #{feat}"
            end
          end
          eff = get_effect_type(vep[vidx[:Consequence]])
          cds_pos  = "NULL"
          cdna_pos = "NULL"
          aa = ""
          cod = ""
          cdna_pos =  vep[vidx[:cDNA_position]] if vep[vidx[:cDNA_position]] and  vep[vidx[:cDNA_position]].size > 1
          cds_pos  =  vep[vidx[:CDS_position]] if vep[vidx[:CDS_position]] and vep[vidx[:CDS_position]].size > 1
          aa =   vep[vidx[:Amino_acids]] if vep[vidx[:Amino_acids]]  and vep[vidx[:Amino_acids]].size > 1
          cods = vep[vidx[:Codons]]  if vep[vidx[:Codons]]  and vep[vidx[:Codons]].size > 1
          inFields =  [
            snp_id.to_s, 
            feat_id.to_s, 
            eff.id.to_s, 
            cdna_pos.to_s, 
            cds_pos.to_s, 
            '"' + aa  + '"',
            '"' + cods + '"' , "NULL",
            "NOW()", "NOW()" 
          ]
          str = "(#{inFields.join(",")})"
          inserts << str
        end
        i+= 1
        if inserts.size > 1000
          insert_effs_sql(inserts, conn)
          puts "Loaded #{i.to_s} effects #{current_chr}"
        end
      end
      insert_effs_sql(inserts, conn)
      puts "Loaded #{i.to_s} effects"
    end
  end

  def self.get_snp(scaffold, pos, wt, alt, species_id)
    snp = Snp.joins(:scaffold).where(scaffolds: { name: scaffold}, wt: wt, position: pos, alt:alt, species_id: species_id).first
 #   puts snp.inspect
    return snp
  end

  def self.insert_primers_sql(inserts, conn)
    adapter_type = conn.adapter_name.downcase.to_sym
    case adapter_type
    when :mysql 
      sql = "INSERT IGNORE INTO `primers` (`snp_id`, `primer_type_id`, `orientation`, `wt`, `alt`, `common`, `created_at`, `updated_at`) VALUES #{inserts.join(", ")} "
    when :mysql2 
      sql = "INSERT IGNORE INTO `primers` (`snp_id`, `primer_type_id`, `orientation`, `wt`, `alt`, `common`, `created_at`, `updated_at`) VALUES #{inserts.join(", ")} "
    when :sqlite
      sql = "INSERT IGNORE INTO `primers` (`snp_id`, `primer_type_id`, `orientation`, `wt`, `alt`, `common`, `created_at`, `updated_at`) VALUES #{inserts.join(", ")} "
    when :postgresql
      sql = "INSERT INTO primers (snp_id, primer_type_id, orientation, wt, alt, common, created_at, updated_at) VALUES #{inserts.join(", ")} ON CONFLICT DO NOTHING "
    else
      raise NotImplementedError, "Unknown adapter type '#{adapter_type}'"
    end

    conn.execute sql
    inserts.clear
  end


  def self.load_primers_mutants(stream, species)
    csv = CSV.new(stream, :headers => true, :col_sep => ",")
    primer_types = Hash.new
    count = 0 
    skipped = 0
    puts "Species: #{species}"
    inserts = Array.new
    ActiveRecord::Base.transaction do
      conn = ActiveRecord::Base.connection
      species = Species.find_by(name: species)
      puts species.inspect
      csv.each do |row|
       next if row["errors"]

       idArr  = row["Marker"].split("_")
       next if idArr[0] == "Error"

       snpArr = row["SNP"].scan(/(\w)(\d+)(\w)/)
       wt  = snpArr[0][0]
       alt = snpArr[0][2]
       line = idArr[2]
       
       scaffold = "IWGSC_CSS_#{idArr[0]}_scaff_#{idArr[1]}"
       pos = idArr[3]
       #snp = get_snp(scaffold, pos, wt, alt, species.id)
       snp_id = get_snp_id(scaffold: scaffold, position:pos, species_id:species.id, alt:alt, wt:wt)
       unless snp_id
        skipped += 1
        next
       end
       pt = row["primer_type"] 
       primer_types[pt] = PrimerType.find_or_create_by(name: pt) unless  primer_types[pt]
       orientation = '\'' + "+" + '\''
       orientation = '\'' + "-" + '\'' if row["orientation"] == "reverse"
       val_a = "NULL"
       val_b = "NULL"
       val_common = "NULL"
       val_a = '\'' + row["A"] + '\'' if row["A"].to_s != ''
       val_b = '\'' + row["B"] + '\'' if row["B"].to_s != ''
       val_common = '\'' + row["common"] + '\'' if row["common"].to_s != ''
       inFields =  [
        snp_id.to_s, 
        primer_types[pt].id.to_s, 
        #'"' + orientation.to_s + '"', 
        #'"' + row["A"].to_s + '"', 
        #'"' + row["B"].to_s + '"', 
        #'"' + row["common"].to_s + '"',
        orientation.to_s, 
        val_a.to_s, 
        val_b.to_s, 
        val_common.to_s,
        "NOW()", "NOW()" 
        ]
       str = "(#{inFields.join(",")})"
       inserts << str
       count += 1
       if inserts.size > 1000 
        puts "Loaded #{count} " 
        insert_primers_sql(inserts, conn)
       end
     end
     insert_primers_sql(inserts, conn) if inserts.size  > 0
   end
   puts "Loaded: #{count} markers. skipped #{skipped}"
  end
end
