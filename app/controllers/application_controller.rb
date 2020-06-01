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
  		ret[sp.id]["chromosomes"] = sp.chromosomes.map { |e| { "id": e.id, "name": e.name} } 
  	end
  	respond_to do |format|
  		format.json do
  			send_data ret.to_json
  		end
  	end
  end

end
