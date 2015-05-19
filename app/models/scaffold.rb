class Scaffold < ActiveRecord::Base
	has_and_belongs_to_many :markers
	belongs_to :assembly
end
