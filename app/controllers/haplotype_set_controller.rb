class HaplotypeSetController < ApplicationController
  def index
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
        @blocks.each do |e| 
          @blocks_csv << [e.assembly, e.chromosome,e.start, e.end, e.block_no, e.chr_length].join(",")
        end
        send_data @blocks_csv.join("\n"), filename: "#{params[:name]}.csv" 
      end 
    end

  end
end
