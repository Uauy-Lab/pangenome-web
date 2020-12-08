module MatchBlock
	module Block
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
  				self.chr_length
  			].join(",")
  		end

      def slices(size: 1000000)
        first = (self.start / size) * size
        last =  (self.end / size) * size
        first.step(last, size).select {|e| e.between?(self.start, self.end) }
      end

      def contains(other)
        return false if other.assembly   != self.assembly
        return false if other.chromosome != self.chromosome
        return other.start >= self.start && other.end <= self.end
      end

      def contains_all(others)
        others.each {|e| return false unless self.contains(e) }
        return true
      end

      def in_range(start, finish)
        left      = self.start <= finish && self.end >= finish 
        right     = self.start <= finish && self.end >= finish 
        contained = self.start >= start  && self.end <= finish
        return  left || right || contained; 
      end
	end

  class BlockSet
    def initialize(blocks)
     @data = blocks
     @data_block_no = Hash.new { |hash, key| hash[key] = [] }
     blocks.each {|b| @data_block_no[b.block_no] << b  }
    end

    def longest_block
      to_color = @data.filter {|d| d.merged_block == 0}
      return false if to_color.size == 0
      to_color.max {|a, b| a.length <=> b.length}
    end

    def color_contained_blocks(blocks, id)
      more_blocks = []
      blocks.each do |b|
        data_to_color = @data.filter{|d| d.merged_block == 0 }
        data_to_color.each do |d|
          ds = @data_block_no[d.block_no].filter{|b| d.assembly == b.assembly }
          more_blocks << d.block_no if b.contains_all(ds)
        end
      end
      color_blocks(more_blocks, id);
    end

    def color_blocks(blocks, id)
      blocks.each do |block |
        blocks_arr = @data_block_no[block].filter{|b| b.merged_block == 0};
        blocks_arr.each { |d| d.merged_block = id }
        self.color_contained_blocks(blocks_arr, id);
      end
    end

    def colored
      @data.each { |e| e.merged_block = 0 }
      i = 1
      loop do
        longest = longest_block
        break unless longest
        color_blocks([longest.block_no], i)
        i += 1
      end
    
      @data.filter{|d| d.merged_block > 0}
      
    end
  end

  MatchBlock = Struct.new(:assembly, :reference, :chromosome, :start, :end, :block_no, :chr_length, :blocks, :merged_block) do
    include Block
  end 

  RegionBlock = Struct.new(:assembly, :reference, :chromosome, :start, :end, :block_no, :chr_length ) do
    include Block
  end 

end