module HaplotypeSetHelper
  MatchBlock = Struct.new(:assembly, :reference, :chromosome, :start, :end, :block_no, :chr_length, :blocks, :merged_block) do 
		
		#attr_accessor :region
		def length
			self.end - self.start
		end

		def to_r
			"#{chromosome}:#{start}-#{self.end}"
		end

		def overlap(other)
			ret = other.assembly == self.assembly
			ret &= other.chromosome == self.chromosome
			ret &= (other.start.between?(self.start, self.end) or other.end.between?(self.start, self.end) )
			ret
		end

		def <=>(other)
    		return self.assembly <=> other.assembly if self.assembly != other.assembly 
    		return self.chromosome <=> other.chromosome if self.chromosome != other.chromosome 
    		return self.start <=> other.start if self.start != other.start 
    		return self.end <=> other.end
  		end

  		def midpoint(round_to:0)
  			val = (self.start + self.end) / 2
  			round_to = round_to * -1
  			val.round(round_to)
  			#val
  		end

  		def first(round_to:0)
  			round_to = round_to * -1
  			self.start.round(round_to)
  		end

  		def last(round_to:0)
  			round_to = round_to * -1
  			self.end.round(round_to)
  		end

  		def to_csv
  			[
  				self.assembly, self.reference, self.chromosome, 
  				self.start, self.end, self.block_no, 
  				self.chr_length, self.blocks
  			].join("\t")

  		end
	end
end