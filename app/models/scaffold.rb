class Scaffold < ActiveRecord::Base
	has_and_belongs_to_many :markers
	belongs_to :assembly
	has_many :scaffold_maps
	
	#has_and_belongs_to_many :chromosomes, :autosave => true
end
