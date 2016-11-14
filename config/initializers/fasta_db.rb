require 'bio-samtools'


class Bio::DB::Fasta::FastaFile
	def fetch_sequence(region)
		query = region.to_region.to_s if region.respond_to?(:to_region)
		query = region.to_s
		command = "#{@samtools} faidx #{@fasta_path} '#{query}'"
		puts command  if $VERBOSE
		@last_command = command
		seq = ""
		yield_from_pipe(command, String, :text ) {|line| seq = seq + line unless line =~ /^>/}

		reference = Bio::Sequence::NA.new(seq)

		if region.respond_to?(:to_region) and region.orientation == :reverse

			reference.reverse_complement!()
		end
		reference
	end
end

class Bio::DB::Fasta::Region
  include Comparable
  attr :str
  def <=>(other)
     return @entry <=> other.entry unless  @entry == other.entry
     return @start <=> other.start unless  @start == other.start
     return @end <=> other.end unless @end == other.end
     return @orientation <=> other.orientation 
  end
  def overlaps (other)
    return false if other.entry != @entry
    return true if other.start >= @start and other.start <= @end
    return true if other.end   >= @start and other.end   <= @end
    return false
  end

  def subset (other)
    return false if other.entry != @entry
    return true if other.start >= @start and other.end <= @end
  end

  def joinRegion (other)
    return nil unless self.overlaps(other)
    out = self.clone 
    out.start = other.start if other.start < out.start
    out.end = other.end if other.end > out.end
    return out 
  end

  def overlap_in_set(set) 
    overlap_set = Set.new 
    set.each do |e| 
      overlap_set << e if self.overlaps(e)
    end
    overlap_set
  end
end


#The path should be a variable. 
#path=fasta:ENV['HOME']+'/References/Reference.fa'
path = '/Volumes/ramirezrVMs/References/IWGSC_CadenzaU_KronosU_v1.fa'
FASTA_DB =  Bio::DB::Fasta::FastaFile.new(fasta:path) 
FASTA_DB.load_fai_entries()   