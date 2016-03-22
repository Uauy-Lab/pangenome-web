require 'bio-gff3'

module Bio::GFFbrowser::FastLineParser
  module_function :parse_line_fast
end

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
    sql = "INSERT IGNORE INTO scaffolds (`name`,`length`, `chromosome`, `assembly_id`,`created_at`, `updated_at`) VALUES #{inserts.compact.join(", ")}"
    conn.execute sql
    inserts.clear
  end

  def self.insert_snp_sql(inserts, conn)
    sql = "INSERT IGNORE INTO snps (`scaffold_id`, `position`, `ref`, `wt`,`alt`,`created_at`, `updated_at`)  VALUES #{inserts.join(", ")} "
    conn.execute sql
    inserts.clear
  end

  def self.insert_snps(stream)

    csv = CSV.new(stream, :headers => false, :col_sep => "\t")
    scaff = Scaffold.new
    inserts = Array.new
    count = 0
    count_not_found = 0
    ActiveRecord::Base.transaction do
      conn = ActiveRecord::Base.connection
      csv.each do |row|
        count += 1
        contig = row[0]
        scaff = Scaffold.find_by_name(contig) if  scaff == nil  or contig != scaff.name
        pos = row[1] 
        ref = row[2]
        wt = row[4]
        alt = row[5]
        unless scaff
          puts "Scaffold not found! #{contig}" 
          count_not_found += 1
          next
        end
        str = "('#{scaff.id}', #{pos}, '#{ref}', '#{wt}', '#{alt}', NOW(), NOW())"
        inserts << str
        if count % 10000 == 0
          puts "Loaded #{count} SNPs (#{contig})" 
          insert_snp_sql(inserts, conn)
        end
      end
      puts "Loaded #{count} SNPs" 
      puts "Unable to load #{count_not_found} SNPs"
      insert_snp_sql(inserts, conn)
    end
    count
  end

  def self.get_snp_hash_for_contig(contig)
    #sql="SELECT snps.id, scaffolds.name,  CONCAT(srnps.wt, snps.position,  snps.alt  )
    # as snp FROM  snps INNER JOIN Scaffolds where scaffolds.name = '#{contig}'";
    snps = Hash.new

    Snp.joins(:scaffold).where("scaffolds.name = ? ", contig).each do |snp|
      str = [snp.wt, snp.position, snp.alt].join("")
      snps[str] = snp.id
    end
    snps
  end

  def self.insert_muts_sql(inserts, conn)
    sql = "INSERT IGNORE INTO mutations (`het_hom`,`wt_cov`, `mut_cov`, `SNP_id`, `total_cov` ,`library_id`, `mm_count`,`created_at`,`updated_at`) VALUES #{inserts.join(", ")}"
   # puts sql
   conn.execute sql
   inserts.clear
 end

 @@scaffolds = nil
 def self.s(name) 
  @@scaffolds = Hash.new unless @@scaffolds
  unless @@scaffolds[name]
    scaff = Scaffold.find_by_name(name)
    raise "Unknown scaffold #{name}" unless scaff
    @@scaffolds[name] = scaff.id  
  end
  @@scaffolds[name] 
end

def self.parse_mm_field(text, snp_id)
    #puts text
    count  = text.match(/Highly repetitive, (\d+) alternate locations/)
    return count[1].to_i, [] if count
    arr = text.split(",")
    count = arr.size
    inserts = Array.new
    arr.each do |name| 
      str = "(#{snp_id}, #{get_scaffold_id(name)}, NOW(), NOW())"
      inserts << str
    end
    return arr.size, inserts
  end

  def self.insert_mm_sql(inserts, conn)
    sql = "INSERT IGNORE INTO multi_maps (`snp_id`,`scaffold_id`,`created_at`,`updated_at`) VALUES #{inserts.join(", ")}"
   # puts sql
   conn.execute sql
   inserts.clear
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
  inserts_mm = Array.new
  count_mm = 0
  csv.each do |row|
    count += 1
    mm_count = 0
    chr, pos,ref, totcov, wt, ma, lib, hohe, wtcov, macov, type, lcov, libs, ins_type,  mm_field = row.to_a

    if current_chr != chr
      current_chr = chr
      snpsIds = get_snp_hash_for_contig(chr)
    end

    snp_str = [wt,pos,ma].join("")
    next unless snpsIds[snp_str]
    snp_id = snpsIds[snp_str]
    if mm_field
      mm_count, mm_insert = parse_mm_field(mm_field, snp_id) 
      inserts_mm.concat mm_insert
    end


    lib = find_library(lib).id


    raise "SNP not found #{chr} #{snp_str}" unless snp_id
    str = "('#{hohe}',#{wtcov},#{macov},#{snp_id},#{totcov}, #{lib},#{mm_count}, NOW(),NOW())"
    inserts << str
    
    if inserts.size % 10000 == 0
      puts "Loaded #{count} mutations (#{chr})" 
      insert_muts_sql(inserts, conn)
    end

    if inserts_mm.size > 10000 
      count_mm += inserts_mm.size
      puts "Loaded #{count_mm} multimap (#{chr})" 
      insert_mm_sql(inserts_mm, conn)
    end

    str = "(#{snp_id},#{})"

  end
  puts "Loaded #{inserts.size} mutations" 
  insert_muts_sql(inserts, conn)
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
        wt = Line.find_or_create_by(name: row["line"])
        wt.species = species
        wt.wildtype =  wt
        lib = Library.new
        lib.name = row["library"]
        lib.line = current_line
        lib.save!       
      end
    end
  end

  def self.find_library(name)
    @libraries = Hash.new unless @libraries
    return @libraries[name] if @libraries[name]
    arr = name.split("_")
    ret = nil
    arr.each do |e|  
      ret = Library.find_by_name(e)
      @libraries[name] = ret
      return ret if ret
    end
    puts  "Library: #{name} not found!"
    ret = Library.find_or_create_by(name: arr[0])
    @libraries[name] = ret
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

  def self.load_deleted_exons(stream)
    csv = CSV.new(stream, :headers => true, :col_sep => ",")
    count = 0
    ActiveRecord::Base.transaction do
      csv.each do |row|
        next unless row["HomDel"] == "TRUE"
        scaff = Scaffold.find_by_name(row["Scaffold"])
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

  @@assemblies = nil
  def self.get_assembly(name)
    @@assemblies = Hash.new unless @@assemblies
    @@assemblies[name] = Assembly.find_or_create_by(name:  name) unless @@assemblies[name]
    @@assemblies[name]
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
        asm = get_assembly(record.source)
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
    sql = "INSERT IGNORE INTO effects (`snp_id`,`feature_id`, `effect_type_id`, `cdna_position`, `cds_position` ,`amino_acids`, `codons`,`created_at`,`updated_at`) VALUES #{inserts.join(", ")}"
    conn.execute sql
    inserts.clear
  end
  
  def self.load_vep_effects_from_vcf(stream)
    i=0
    vep_headers = [:Allele, :Gene, :Feature, :Feature_type, :Consequence, :cDNA_position, :CDS_position, :Protein_position, :Amino_acids, :Codons, :Existing_variation, :DISTANCE, :STRAND]
    head_arr = vep_headers.each_with_index.map { |e, i| [e , i] }
    vidx =  Hash[head_arr.to_a]
    scaff = Scaffold.new
    features = Hash.new
    #VEP header: Allele|Gene|Feature|Feature_type|Consequence|cDNA_position|CDS_position|Protein_position|Amino_acids|Codons|Existing_variation|DISTANCE|STRAND
    
    current_chr = ""
    inserts = Array.new
    snpsIds = Hash.new
    ActiveRecord::Base::transaction do 
      conn = ActiveRecord::Base.connection
      stream.each_line do | line |
        line.chomp!
        next if line.length == 0 or line =~ /^#/
        
        vcf = Bio::DB::Vcf.new(line)
        scaff = Scaffold.find_or_create_by(name: vcf.chrom) unless scaff.name == vcf.chrom
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
              features[feat] = Feature.find_by_name(feat).id unless features[feat] 
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
            '"' + cod + '"' ,
            "NOW()", "NOW()" 
          ]
          str = "(#{inFields.join(",")})"
          inserts << str
        end
        i+= 1
        if inserts.size > 10000
          insert_effs_sql(inserts, conn)
          puts "Loaded #{i.to_s} effects #{current_chr}"
        end
      end
      insert_effs_sql(inserts, conn)
      puts "Loaded #{i.to_s} effects"
    end
  end
end