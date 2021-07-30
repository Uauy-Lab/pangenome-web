require_relative "../LoadFunctions.rb"
require 'bio'
require 'csv'  

namespace :alignments do
	desc "Load scaffolds from a fai file, with the scaffold names as in ensambl (IWGSC_CSS_1AL_scaff_1000404)"
	task :load_csv_gz, [:filename] => :environment do |t, args|
		ActiveRecord::Base.transaction do
			Zlib::GzipReader.open(args[:filename]) do |stream|
				AlignmentHelper.load(stream)
			end
		end
	end
end
