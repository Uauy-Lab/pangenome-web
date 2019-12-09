class HaplotypeSetController < ApplicationController
  def index
  end

  def show
  	
  	@haplotype_set = HaplotypeSet.find_by(name: params[:name])
  	@blocks = HaplotypeSetHelper.find_calculated_block(params[:name])
  	#@blocks = @blocks.pluck(:assembly_name, :chromosome, :start, :end, :block_no)

  	

  	respond_to do |format|
      format.html
      format.csv do 
        @blocks_csv = Array.new
        @blocks_csv << ["assembly","chromosome","start","end","block_no", "chr_length"].join(",")
        
        @blocks.each do |e| 
          @blocks_csv << [e.assembly.name, e.scaffold.name,e.region.start, e.region.end, e.block_no, e.scaffold.length].join(",")
        end
        send_data @blocks_csv.join("\n"), filename: "#{params[:name]}.csv" 
      end 
    end

  end
end
