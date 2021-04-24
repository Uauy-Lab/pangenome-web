require 'bio-pangenome'

class HaplotypeSetController < ApplicationController
  def index
  end

  

  def show_single
    chr_name = params[:chr_name] 
    species  = params[:species]
    hap_set  = params[:hap_set]    
    asm = params[:asm]
 
    @s_blocks =HaplotypeSetHelper.find_calculated_block_pseudomolecules(hap_set, chromosome:chr_name, species: species)
    sp = Species.find_by(name: species)
    @blocks_csv = Array.new
    @blocks_csv   << ["assembly","assembly_id","reference","chromosome","start","end","block_no", "chr_length"].join(",")
    @s_blocks.each do |e| 
      asm = e.assembly
      asm = sp.assembly(e.assembly).description if sp.assembly(e.assembly).description 
      @blocks_csv << [asm , e.assembly, e.reference, e.chromosome,e.start, e.end, e.block_no, e.chr_length].join(",")
    end

    respond_to do |format|
      format.csv do
        send_data @blocks_csv.join("\n"), filename: "#{species}_#{hap_set}_#{chr_name}.csv" 
      end
    end
  end
  
  def show
    @chr = params[:chr_name] 
    @species  = params[:species]
    @hap_sets = HaplotypeSetHelper.find_hap_sets(species: @species, chr: @chr)
    session_chromosome(chr: @chr)

    @features = []

    @feature = Feature.find_by(name: params[:gene]) 
    @features.push @feature if @feature

    @features = @features.map() {|f| f.name }.to_json


    species = Species.find_by_name(@species)
    asms = species.assemblies
    asms = asms.select {|a| a.haplotype_blocks.count > -0}
    @assemblies =  asms.map {|a| "'#{a.description}'"}.join(",")

    #http://localhost:3000/haplotype_set/Wheat/haps/6A.csv
    @csv_paths = Hash.new
    @hap_sets.each do |h_s| 
      @csv_paths[h_s.name] =  "/#{@species}/haplotype/#{@chr}/#{h_s.name}.csv" 
    end

    @hap_set  = session_hap_set
 
  	respond_to do |format|
      format.html
    end
  end
end
