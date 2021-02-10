require_relative "../LoadFunctions.rb"
require_relative "../bed.rb"
require 'bio'
require 'csv'  

namespace :ibspy  do
	

	task :load_scores,[:path] => :environment do |t, args|
		puts "Loading region scores"
		ActiveRecord::Base.transaction do 
			CSV.foreach(args[:path], headers:true) do |row|
				IBSpyHelper.load(
					row['species'], 
					row['reference'],
					row['library'], 
					row['line'], 
					row['analysis'],
					row['description'],
					row['path']
					)
				
				
				
			end
			#
			#print species.inspect
		end
	end 
end