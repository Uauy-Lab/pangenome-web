require 'csv'
require_relative '../lib/LoadFunctions.rb'

libraries = Hash.new
File.open("/Users/ramirezr/Dropbox/jic/Tilling/ForWebsite/library_names_cadenza_renamed.txt") do |stream|
	count = 0
	csv = CSV.new(stream, :headers => true, :col_sep => "\t")
	csv.each do |row|
		libraries[row["library"]] = row["MutantName"]
	end
end

