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

#The path should be a variable. 
FASTA_DB =  Bio::DB::Fasta::FastaFile.new(fasta:ENV['HOME']+'/References/Reference.fa') 
FASTA_DB.load_fai_entries()