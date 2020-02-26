require 'bio-pangenome'

class HaplotypeSetController < ApplicationController
  def index
  end

  

  def find_longest_block(blocks)
    longest = blocks.first
    blocks.each { |e| longest = e if longest.length < e.length  }
    longest
  end

  


  def show
  	#puts params.inspect
  	@haplotype_set = HaplotypeSet.find_by(name: params[:name])

    hap_set  = params[:name]
    chr_name = params[:chr_name]

    @blocks = Rails.cache.fetch("#{hap_set}/#{chr_name}", expires_in: 12.hours) do
      tmp_B = HaplotypeSetHelper.find_calculated_block(hap_set, chromosome:chr_name)
      HaplotypeSetHelper.to_blocks(tmp_B)
    end

  	


    asm = params[:asm]
  	#@blocks = @blocks.pluck(:assembly_name, :chromosome, :start, :end, :block_no)
    #@blocks = HaplotypeSetHelper.find_longest_block(params[:name])
  	@chr = params[:chr_name]

  	respond_to do |format|
      format.html
      format.csv do 
        @blocks_csv = Array.new
        @blocks_csv << ["assembly","chromosome","start","end","block_no", "chr_length"].join(",")
        
        #@blocks = @blocks.sort!
        @s_blocks = Rails.cache.fetch("#{hap_set}/#{chr_name}/#{asm}") do
          tmp = HaplotypeSetHelper.scale_blocks(@blocks, target: asm)
          tmp.sort!
        end

        @s_blocks.each do |e| 
          @blocks_csv << [e.assembly, e.chromosome,e.start, e.end, e.block_no, e.chr_length].join(",")
        end
        send_data @blocks_csv.join("\n"), filename: "#{params[:name]}.csv" 
      end 
    end

  end
end
