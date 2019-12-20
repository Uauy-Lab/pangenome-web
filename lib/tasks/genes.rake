require_relative "../LoadFunctions.rb"
require 'bio'
require 'csv'  
require 'bio-pangenome'
namespace :genes do
  desc "Load the genes, from the ENSEMBL fasta file."
  task :ensembl_genes, [:gene_set, :filename] => :environment do |t, args|
    puts "Loading genes"
    ActiveRecord::Base.transaction do
      gene_set = GeneSet.find_or_create_by(:name=>args[:gene_set])
      Bio::FlatFile.open(Bio::FastaFormat, args[:filename]) do |ff|
        ff.each do |entry|
          arr = entry.definition.split( / description:"(.*?)" *| / )
          g = Gene.new 
          g.gene_set = gene_set
          g.name = arr.shift
          arr.each { |e| g.add_field(e) }
          g.save!
        end
      end
    end
  end

  desc "Load genes from a gff file"
  task :load_gff_gz, [:filename,:asm] => :environment do |t, args|
    puts "Loading gff"
    Zlib::GzipReader.open(args[:filename]) do |stream|
      LoadFunctions.load_features_from_gff(stream,assembly:args[:asm])
    end
  end

  desc "Load the mapping of genes across assembles. The header is [transcript query subject var_query var_subject  aln_type length pident Ns_query Ns_subject  Ns_total Flanking]. The transcript is the CS gene. The query and subject will have as first field the 'mRNA'."
  task :load_pangenome_mapping_gz, [:filename, :id, :asm] => :environment do |t, args|
    puts "Loading gene mappings across the pangenome"
    ActiveRecord::Base.transaction do
      aln_set = AlignmentSet.find_or_create_by(name: args[:id])
      throw Exception.new "#{args[:id]} has been loaded" unless aln_set.alignments_count.nil?
      base_asm     = LoadFunctions.find_assembly(args[:asm])
      base_feat    = LoadFunctions.get_feature_type("gene")
      base_regions = FeatureHelper.find_features_in_assembly(args[:asm], "gene")
      #puts "ID in object: #{aln_set.id}"
      inserts = Array.new
      i = 0
      conn = ActiveRecord::Base.connection
      Zlib::GzipReader.open(args[:filename]) do |stream|
        csv = CSV.new(stream, :headers => true, :col_sep => "\t")
        csv.each do |row|
          
          next if row["Ns_total"].to_i > 0

          pident = row["pident"].to_f
          len = row["length"].to_i
          tmp =  "(" + [i.to_s, aln_set.id, base_regions[row["transcript"]],base_feat.id, base_asm.id, pident, len, "NOW()", "NOW()"].join(", ") + ")"
          inserts << tmp

          query_asm     = LoadFunctions.find_assembly(row["var_query"])
          query_regions = FeatureHelper.find_features_in_assembly(row["var_query"], "gene")
          query_parsed = BioPangenome.parseSequenceName("NA",row["query"])

          tmp =  "(" + [i.to_s, aln_set.id, query_regions[query_parsed.gene],base_feat.id, query_asm.id, pident, len, "NOW()", "NOW()"].join(", ") + ")"
          inserts << tmp


          subject_asm     = LoadFunctions.find_assembly(row["var_subject"])
          subject_regions = FeatureHelper.find_features_in_assembly(row["var_subject"], "gene")
          subject_parsed = BioPangenome.parseSequenceName("NA",row["subject"])

          tmp =  "(" + [i.to_s, aln_set.id, subject_regions[subject_parsed.gene],base_feat.id, subject_asm.id, pident, len, "NOW()", "NOW()"].join(", ") + ")"
          inserts << tmp
          if inserts.size >= 10000
            puts "Inserted #{i} alignments. (Last: #{row})"
            LoadFunctions.insert_alignment_mappings_sql(inserts, conn)
            
          end
          i += 1
        end
      end
      LoadFunctions.insert_alignment_mappings_sql(inserts, conn)
      puts "Inserted #{i} alignments."
      aln_set.alignments_count = i
      aln_set.save!
    end
  end

  desc "Load feature maps. The header is. The header is [line,projected_gene,transcript,chromosome,gene]."
  task :load_feature_mapping_gz, [:filename, :name, :base_asm,:species] => :environment do |t, args|
    puts "Loading gene mappings across the pangenome"
    ActiveRecord::Base.transaction do
      feature_align_set = FeatureMappingSet.find_or_create_by(name: args[:name])
      throw Exception.new "#{args[:name]} has been loaded" unless feature_align_set.mapping_count.nil?
      base_regions = FeatureHelper.find_features_in_assembly(args[:base_asm], "gene", column: :id)
      species = LoadFunctions.find_species(args[:species])
      conn = ActiveRecord::Base.connection
      i = 0
      inserts = Array.new
      Zlib::GzipReader.open(args[:filename]) do |stream|
        csv = CSV.new(stream, :headers => true, :col_sep => ",")
        csv.each do |row|
          if inserts.size >= 10000
            puts "Inserted #{i} feature mappings. (Last: #{row})"
            FeatureHelper.insert_feature_mappings_sql(inserts, conn)
          end
          base_gene = base_regions[row["gene"]]
          projected_genes = FeatureHelper.find_features_in_assembly(row["line"], "gene", column: :id)
          #puts " projected genes #{projected_genes.size}"
          projected_gene_id = projected_genes[row["projected_gene"]]
          chromosome = FeatureHelper.find_chromosome(row["chromosome"],species)
          assembly   = FeatureHelper.find_assembly(row["line"]) 
          arr = [assembly.id, base_gene, chromosome.id, feature_align_set.id, projected_gene_id, "NOW()","NOW()"]
          #puts row.inspect
          #puts arr.join(",")
          inserts <<  "(" + arr.join(",") + ")"
          i += 1
          #break if i > 20
          
        end
      end
      if inserts.size > 0
            puts "Inserted #{i} feature mappings."
            FeatureHelper.insert_feature_mappings_sql(inserts, conn)
      end
      feature_align_set.mapping_count = i
      feature_align_set.save
      #throw Exception.new "Testing! Rollback" 

    end
  end
end