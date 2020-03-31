require_relative "../LoadFunctions.rb"
require_relative "../bed.rb"
require 'bio'
require 'csv'  
require 'bio-pangenome'

namespace :haplotypes do 
	desc "Load precalculated haplotype blocks"
	task :load_blocks_v0, [:filename, :analysis_id, :description] => :environment do |t,args|
		puts "Loading blocks"
		ActiveRecord::Base.transaction do
			feat_type = LoadFunctions.get_feature_type("haplotype_block")
			hap_set = HaplotypeSet.find_by(name:args[:analysis_id])
			throw Exception.new "#{args[:analysis_id]} already exists. Use a new name." unless hap_set.nil?
			feat_type = LoadFunctions.get_feature_type("haplotype_block")
			hap_set = HaplotypeSet.find_or_create_by(name:args[:analysis_id], description:args[:description])
			i = 1
			CSV.foreach(args[:filename], col_sep: "\t", headers:true) do |row|
				#puts row.inspect
				next unless row["ref_assembly"]
				next if row["block_start"] == "NA"
				LoadFunctions.new_haplotype_block_v0(row, hap_set, assembly_col: "subject", block_no: i)
				LoadFunctions.new_haplotype_block_v0(row, hap_set, assembly_col: "target", block_no: i)
				i += 1
				#break
			end
			#throw Exception.new "Testing! Rollback"
		end
	end

	desc "Load the called blocks. the headers of the file are: 
	'ref	query	chrom	ref_start	ref_end	source	block_no	
	ref_assembly	block_size	ref_chrom."
	task :load_blocks, [:filename, :analysis_id, :description] => :environment do |t,args|
		puts "Loading blocks"

		ActiveRecord::Base.transaction do
			feat_type = LoadFunctions.get_feature_type("haplotype_block")
			hap_set = HaplotypeSet.find_by(name:args[:analysis_id])
			throw Exception.new "#{args[:analysis_id]} already exists. Use a new name." unless hap_set.nil?
			
			hap_set = HaplotypeSet.find_or_create_by(name:args[:analysis_id], description:args[:description])
			i = 1
			CSV.foreach(args[:filename], col_sep: "\t", headers:true) do |row|
				#puts row.inspect
				next unless row["ref_assembly"]
				next if row["ref_start"] == "NA"
				current = LoadFunctions.new_haplotype_block(row, hap_set, assembly_col: "query")
				#puts current.inspect
				i += 1
				#break
			end
			#throw Exception.new "Testing! Rollback"
		end
	end

	desc "Export haplotype blocks based on all the possible reference"
	task :export_haplotype_coordinates, [:output_filename, :analysis_id, :asm] => :environment do |t, args|
		puts "Exporting"
		hap_set = HaplotypeSet.find_by(name: args[:analysis_id])
		blocks = HaplotypeSetHelper.find_all_calculated_blocks(args[:analysis_id])
		s_blocks = HaplotypeSetHelper.scale_blocks(blocks, target: args[:asm])
		s_blocks.sort!
        out = File.open(args[:output_filename], "w")
        out.puts ["assembly","chromosome","start","end","block_no", "chr_length"].join(",")
        s_blocks.each do |e| 
          out.puts [e.assembly, e.chromosome,e.start, e.end, e.block_no, e.chr_length].join(",")
        end
        out.close
	end

	desc "Export haplotype blocks based on all the possible reference"
	task :export_haplotype_coordinates_tag, [:output_filename, :analysis_id,:bed4] => :environment do |t, args|
		puts "Exporting"
		hap_set = HaplotypeSet.find_by(name: args[:analysis_id])
		blocks = HaplotypeSetHelper.find_all_calculated_blocks(args[:analysis_id])
		s_blocks = HaplotypeSetHelper.scale_blocks(blocks, target: nil)
		#puts "SSSBLOCKS #{s_blocks.inspect}"
		s_blocks.sort!
        out = File.open(args[:output_filename], "w")

        beds = Bio::BED::readBed4(args[:bed4])
        out.puts ["assembly","chromosome","start","end","block_no", "chr_length", "Regions", "Mid-Region"].join(",")

        s_blocks.each do |e| 
        	regions = Bio::BED::getBlockRegion(beds,e)
        	mid = (e.start + e.end) / 2
        	mid_reg = Bio::BED::Bed4.new(e.chromosome, mid - 1, mid, e.block_no)
        	md_regs = Bio::BED::getBlockRegion(beds,mid_reg)
        	#puts regions.inspect
          out.puts [e.assembly, e.chromosome,e.start, e.end, e.block_no, e.chr_length, regions.join("-"),md_regs.join("-")].join(",")
        end
        out.close
	end

	desc "Convert coordinates from calculated blocks in file"
	task :convert_gene_coordinates, [:input, :output, :species] => :environment do |t,args|
		
		species = Species.find_by(name: args[:species])
		#puts species.inspect
		asm   = species.cannonical_assembly.first
		genes = FeatureHelper.find_features_in_assembly(asm.name, "gene",column: nil)
		#puts genes.size
		#puts genes.first
		#MatchBlock = Struct.new(:assembly, :reference, :chromosome, :start, :end, :block_no, :chr_length, :blocks, :merged_block) 
		csv   = CSV.new(File.open(args[:input]), headers: true, col_sep: "\t")
		ret = []
		csv.each_with_index do |row, i|
			next if row["start_transcript"] == "NA"

			start_transcript = genes[row["start_transcript"]]

			end_transcript = genes[row["end_transcript"]]
			aln_type = row["aln_type"]
			alns     = aln_type.split("->")

			block = HaplotypeSetHelper::MatchBlock.new(alns[0], asm.name, start_transcript.chr, start_transcript.start, end_transcript.to, i+1, 0, [],"")
			begin
				ret << HaplotypeSetHelper.scale_block(block, asm, species, target: alns[0])
			rescue Exception => e
				ret << HaplotypeSetHelper.scale_block(block, asm, species, target: asm.name)
			end
			block.assembly = alns[1]
			begin
				ret << HaplotypeSetHelper.scale_block(block, asm, species, target: alns[1])
			rescue Exception => e
				ret << HaplotypeSetHelper.scale_block(block, asm, species, target: asm.name)
			end
		end
		ret.flatten!
		csv.close

		out = File.open(args[:output], "w")
		out.puts ["assembly","reference","chromosome","start","end","block_no", "chr_length", "start_transcript", "end_transcript"].join(",")
		ret.each do |e|
			out.puts [e.assembly, e.reference, e.chromosome,e.start, e.end, e.block_no, e.chr_length, e.merged_block[0].name, e.merged_block[1].name].join(",")
		end
		out.close

	end
end