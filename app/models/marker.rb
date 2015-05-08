class Marker < ActiveRecord::Base
	has_many :positions
	has_and_belongs_to_many :scaffolds
end
