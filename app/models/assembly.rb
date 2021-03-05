class Assembly < ActiveRecord::Base
	has_many :scaffolds
	has_many :haplotype_blocks

	def chromosome(name)
		self.chromosomes unless @chromosomes
		return @chromosomes[name]
	end

	def chromosomes
		@chromosomes = Rails.cache.fetch("assembiles/#{self.id}/chromosomes") do
			ret = Hash.new
			self.scaffolds.each do |scaff|
				puts "..."
				puts scaff.inspect
				arr = scaff.name.split("_")
				ret[arr[0]] = scaff
			end
			ret
		end
		@chromosomes.values
	end

	# def haplotype_block_count()

	# end

end
