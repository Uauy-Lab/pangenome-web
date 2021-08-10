class Assembly < ActiveRecord::Base
	has_many :scaffolds
	has_many :haplotype_blocks
	scope :in_pseudomolocule, -> { where(is_pseudomolecule: true) }
	
	def chromosome(name)
		self.chromosomes unless @chromosomes
		return @chromosomes[name]
	end

	def chromosomes
		@chromosomes = Rails.cache.fetch("assembiles/#{self.id}/chromosomes") do
			ret = Hash.new
			self.scaffolds.each do |scaff|
				arr = scaff.name.split("_")
				ret[arr[0]] = scaff
			end
			ret
		end
		@chromosomes.values
	end

	def self.cached_from_id(id)
		@@assembly ||= Hash.new  
		@@assembly[id] ||= Assembly.find(id)
		@@assembly[id] 
	end

end
