require 'bio-pangenome'

class HaplotypeSetController < ApplicationController
  def index
  end

  

  def find_longest_block(blocks)
    longest = blocks.first
    blocks.each { |e| longest = e if longest.length < e.length  }
    longest
  end

  def scale_blocks(blocks)
    puts "scaling"
    ret = []
    puts "__________________________"
    blocks.each do |block|
      puts block.inspect if block.assembly == "spelta"
      m_blocks = HaplotypeSetHelper.find_base_blocks(block)
      
      #puts features.map{|f| f.to_r}.join(",") 
      ret << m_blocks
      #ret << find_longest_block( m_blocks) if m_blocks.size > 0
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
        @s_blocks = scale_blocks(@blocks)

        @s_blocks.each do |e| 
          @blocks_csv << [e.merged_block.assembly, e.chromosome,e.start, e.end, e.block_no, e.chr_length].join(",")
        end
        send_data @blocks_csv.join("\n"), filename: "#{params[:name]}.csv" 
      end 
    end

  end
end
