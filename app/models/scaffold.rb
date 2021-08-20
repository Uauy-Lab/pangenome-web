class Scaffold < ActiveRecord::Base
	#has_and_belongs_to_many :markers
	belongs_to :assembly
	#has_many :scaffold_maps
	belongs_to :chromosome, foreign_key: 'chromosome'
	#has_and_belongs_to_many :chromosomes, :autosave => true

	def self.cached_from_id(id)
		@@scaffolds ||= Hash.new  
		@@scaffolds[id] ||= Scaffold.find(id)
		@@scaffolds[id] 
	end

	def self.cached_from_name(name)
		@@scaffolds_name ||= Hash.new  
		@@scaffolds_name[name] ||= Scaffold.find_by(name: name)
		@@scaffolds_name[name] 
	end

end
