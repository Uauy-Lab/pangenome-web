class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
      
  include ApplicationHelper  

  def species
  	all_species = Species.all.map do |sp|
  		sp
  	end 

  	ret = Hash.new
  	all_species.each do |sp|
  		ret[sp.id] = Hash.new
  		ret[sp.id]["name"] = sp.name
  		chrs = sp.chromosomes.map { |e| { 
			  "id": e.id, 
			  "name": e.name,
			  "hap_sets": HaplotypeSetHelper.find_hap_sets(species: sp.name, chr: e.name)
			  } } 
		ret[sp.id]["chromosomes"] = chrs.select() { |c|  
			c["hap_sets"] && c["hap_sets"].size > 0 } 
		ret[sp.id]["chromosomes"] = chrs
	end
	
  	respond_to do |format|
  		format.json do
  			send_data ret.to_json
  		end
  	end
  end

end
