class Chromosome < ActiveRecord::Base
	belongs_to :species
	belongs_to :assembly
end
