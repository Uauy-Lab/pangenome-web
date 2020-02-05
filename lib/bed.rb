module Bio::BED
	Bed4 = Struct.new(:chromosome, :start0, :end, :name) do
		def start
			start0 + 1
		end	

		def overlap(other)

			ret = other.chromosome == self.chromosome
			ret &= (other.start.between?(self.start, self.end) or 
				other.end.between?(self.start, self.end) or 
				self.contains(other) or 
				self.is_ccontained(other) )
			#puts "#{self.to_r}\t#{other.to_r}\t#{ret}" if ret
			ret
		end

		def contains(other)
			self.start <= other.start and other.end <= self.end 
		end

		def is_ccontained(other)
			other.start <= self.start and self.end <= other.end 
		end

		def to_r
			"#{chromosome}:#{start}-#{self.end}"
		end
	end

	def self.readBed4(path)
		arr = []
		File.foreach(path) do |line|  
			line.chomp!
			tmp = line.split("\t")
			arr << Bed4.new(tmp[0],tmp[1].to_i,tmp[2].to_i,tmp[3])
		end
		arr
	end


	def self.getBlockRegion(beds, block)
		regions = []
		beds.each do |b|
			regions << b.name  if b.overlap(block)
		end
		regions
	end

end