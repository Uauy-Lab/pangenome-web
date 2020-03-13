class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def getSelectedSpecies
  	if session[:selected_species].nil?
  		session[:selected_species] = Species.all.first 
  	end
  	session[:selected_species]
  end
end
