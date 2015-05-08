class MapPosition < ActiveRecord::Base
	belongs_to :genetic_map
	belongs_to :marker
	belongs_to :chromosome
	belongs_to :scaffold
end
