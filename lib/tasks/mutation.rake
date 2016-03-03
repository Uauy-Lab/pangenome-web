require_relative "../LoadFunctions.rb"
require 'bio'
require 'bio-samtools'
require 'bioruby-polyploid-tools'
require 'csv'  

namespace :mutation do
  desc "Laod snps, from the following header 'Chrom/Scaffold	Pos	Ref	TotCov	WT	MA	Lib	Ho/He	WTCov	MACov	Type	LCov	#libs	InsertType	multimap' It only inserts each position once, however it doesn't validate if the position already exists. It only uses: scaffold, position, ref, wt, alt"
  task :loadSNPs, [:filename] => :environment do |t, args|
  	ActiveRecord::Base.transaction do
  		 File.open(args[:filename]) do |stream|
  			LoadFunctions.insert_snps(stream)
  		end
  	end
  end


  desc "Laod mutations, from the following header 'Chrom/Scaffold	Pos	Ref	TotCov	WT	MA	Lib	Ho/He	WTCov	MACov	Type	LCov	#libs	InsertType	multimap' It only inserts each position once, however it doesn't validate if the position already exists. It only uses: scaffold, position, ref, wt, alt"
  task :load, [:filename] => :environment do |t, args|
  	ActiveRecord::Base.transaction do
  		 File.open(args[:filename]) do |stream|
  			LoadFunctions.insert_mutations(stream)
  		end
  	end
  end
end
