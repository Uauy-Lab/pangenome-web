require 'bio-pangenome'

class HaplotypeSetController < ApplicationController
  def index
  end

  

  def find_longest_block(blocks)
    longest = blocks.first
    blocks.each { |e| longest = e if longest.length < e.length  }
    longest
  end

  def scale_blocks(blocks, target: "lancer")
    puts "scaling"
    ret = []
    puts "__________________________"

    prev_asm = nil
    features = []
    seen_blcks = []
    block_id = nil
    blocks.each_with_index do |block, i|
      features += HaplotypeSetHelper.find_reference_features_in_block(block, type: 'gene')
      seen_blcks <<  block.block_no
      if prev_asm && block_id == block.block_no
        
        if target
          features = FeatureHelper.find_mapped_features(features, assembly: target)
        end

        features.sort!.uniq
        #puts features.map { |e| e.name  }
        #puts seen_blcks
        

        ret << HaplotypeSetHelper.features_to_blocks(features,block_no: block_id, asm:prev_asm)
        ret << HaplotypeSetHelper.features_to_blocks(features,block_no: block_id, asm:block.assembly)
        features.clear
        #break if i > 10
      end
      block_id = block.block_no
      prev_asm = block.assembly
      #m_blocks = HaplotypeSetHelper.find_base_blocks(block)
      #ret << m_blocks
    end

    ret.flatten!
    puts "........."
    ret 
  end
  def show
  	puts params.inspect
  	@haplotype_set = HaplotypeSet.find_by(name: params[:name])
  	@blocks = HaplotypeSetHelper.find_calculated_block(params[:name], chromosome: params[:chr_name])
    


  	#@blocks = @blocks.pluck(:assembly_name, :chromosome, :start, :end, :block_no)
    #@blocks = HaplotypeSetHelper.find_longest_block(params[:name])
  	@chr = params[:chr_name]

  	respond_to do |format|
      format.html
      format.csv do 
        @blocks_csv = Array.new
        @blocks_csv << ["assembly","chromosome","start","end","block_no", "chr_length"].join(",")
        @blocks = HaplotypeSetHelper.to_blocks(@blocks)


        #@blocks = @blocks.sort!
        @s_blocks = scale_blocks(@blocks)
        @s_blocks.sort!
        @s_blocks.each do |e| 
          @blocks_csv << [e.assembly, e.chromosome,e.start, e.end, e.block_no, e.chr_length].join(",")
        end
        send_data @blocks_csv.join("\n"), filename: "#{params[:name]}.csv" 
      end 
    end

  end
end
